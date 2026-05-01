import os
import datetime
import uuid

import psycopg
from flask import Flask, abort, redirect, render_template, url_for, request, make_response

app = Flask(__name__)
app.config.from_object('config')

DIFFICULTY_LABELS = {
    1: 'Beginner',
    2: 'Intermediate',
    3: 'Advanced'
}


def difficulty_label(value):
    return DIFFICULTY_LABELS.get(value, 'Unknown')


def format_duration(value):
    if value is None:
        return ''
    if isinstance(value, datetime.timedelta):
        total_minutes = int(value.total_seconds() // 60)
        if total_minutes < 60:
            return f"{total_minutes} mins"
        hours = total_minutes // 60
        minutes = total_minutes % 60
        return f"{hours}h {minutes}m" if minutes else f"{hours}h"
    return str(value)


app.jinja_env.filters['difficulty_label'] = difficulty_label
app.jinja_env.filters['format_duration'] = format_duration

CORRECT_ANSWER_TEXT = {
    "Which of the following is an example of personal information?": "Your home address",
    "What should you do if a website asks for unnecessary personal details?": "Leave the site and do not provide the information",
    "What is the main goal of a phishing attack?": "To steal your personal information or login details",
    "Which of these is a red flag in an email?": "An urgent request asking you to click a link",
    "Which of the following is the strongest password?": "X#9mP!qL2$vR",
    "What is a password manager used for?": "To securely store and organise your passwords",
    "Which of the following should you avoid posting on social media?": "Your location and daily routine",
    "What should you do with your social media privacy settings?": "Set them to private so only trusted people can see",
}


def get_db_connection():
    return psycopg.connect(
        host=os.getenv('DB_HOST', 'localhost'),
        port=os.getenv('DB_PORT', '5432'),
        dbname=os.getenv('DB_NAME'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
        row_factory=psycopg.rows.dict_row,
    )


def get_user_id():
    user_id = request.cookies.get('user_id')
    if not user_id:
        user_id = str(uuid.uuid4())
    return user_id


def set_user_cookie(response, user_id):
    response.set_cookie('user_id', user_id, max_age=365*24*3600)  # 1 year


def init_user_tables():
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute('''
                CREATE TABLE IF NOT EXISTS user_lesson_progress (
                    user_id VARCHAR(36) NOT NULL,
                    lesson_id INTEGER NOT NULL,
                    progress REAL DEFAULT 0,
                    PRIMARY KEY (user_id, lesson_id)
                )
            ''')
            cur.execute('''
                CREATE TABLE IF NOT EXISTS user_slide_completion (
                    user_id VARCHAR(36) NOT NULL,
                    lesson_id INTEGER NOT NULL,
                    slide_number INTEGER NOT NULL,
                    completed BOOLEAN DEFAULT FALSE,
                    PRIMARY KEY (user_id, lesson_id, slide_number)
                )
            ''')
            conn.commit()


# Initialize tables on startup
init_user_tables()


def fetch_lessons(user_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                'SELECT l.lesson_id, l.name, l.description, l.difficulty, l."time", COALESCE(ulp.progress, 0) as progress, l.slide_count FROM public.lessons l LEFT JOIN user_lesson_progress ulp ON l.lesson_id = ulp.lesson_id AND ulp.user_id = %s ORDER BY l.lesson_id',
                (user_id,)
            )
            return cur.fetchall()


def fetch_lesson(lesson_id, user_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                'SELECT l.lesson_id, l.name, l.description, l.difficulty, l."time", COALESCE(ulp.progress, 0) as progress, l.slide_count FROM public.lessons l LEFT JOIN user_lesson_progress ulp ON l.lesson_id = ulp.lesson_id AND ulp.user_id = %s WHERE l.lesson_id = %s',
                (user_id, lesson_id)
            )
            return cur.fetchone()


def fetch_slide(lesson_id, slide_number):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                'SELECT slide_id, lesson_id, count, title, body, type, completed FROM public.slides WHERE lesson_id = %s AND count = %s',
                (lesson_id, slide_number),
            )
            return cur.fetchone()


def get_youtube_embed_url(url):
    if not url:
        return None
    if 'youtube.com/watch' in url and 'v=' in url:
        query = url.split('v=', 1)[1]
        video_id = query.split('&', 1)[0]
        return f'https://www.youtube.com/embed/{video_id}'
    if 'youtu.be/' in url:
        video_id = url.split('youtu.be/', 1)[1].split('?', 1)[0]
        return f'https://www.youtube.com/embed/{video_id}'
    return None


def assign_correct_answers(questions):
    for question in questions:
        responses = question.get('responses') or []
        correct_text = CORRECT_ANSWER_TEXT.get(question['question'])
        chosen_response_id = None
        for response in responses:
            if correct_text and response['response_text'] == correct_text:
                response['is_correct'] = True
                chosen_response_id = response['response_id']
            else:
                response['is_correct'] = False

        if chosen_response_id is None and responses:
            responses[0]['is_correct'] = True
            chosen_response_id = responses[0]['response_id']
            for response in responses[1:]:
                response['is_correct'] = False

        question['correct_response_id'] = chosen_response_id
        question['responses'] = responses


def update_slide_completion(user_id, lesson_id, slide_number, completed=True):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                'INSERT INTO user_slide_completion (user_id, lesson_id, slide_number, completed) VALUES (%s, %s, %s, %s) ON CONFLICT (user_id, lesson_id, slide_number) DO UPDATE SET completed = %s',
                (user_id, lesson_id, slide_number, completed, completed),
            )
            conn.commit()


def update_lesson_progress(user_id, lesson_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            # Get total slides
            cur.execute('SELECT COUNT(*) FROM public.slides WHERE lesson_id = %s', (lesson_id,))
            total_slides = cur.fetchone()['count']
            
            # Get completed slides for user
            cur.execute('SELECT COUNT(*) FROM user_slide_completion WHERE user_id = %s AND lesson_id = %s AND completed = true', (user_id, lesson_id))
            completed_slides = cur.fetchone()['count']
            
            progress = (completed_slides / total_slides * 100) if total_slides > 0 else 0
            
            cur.execute(
                'INSERT INTO user_lesson_progress (user_id, lesson_id, progress) VALUES (%s, %s, %s) ON CONFLICT (user_id, lesson_id) DO UPDATE SET progress = %s',
                (user_id, lesson_id, progress, progress),
            )
            conn.commit()


def get_user_statistics(user_id):
    """Calculate user statistics: completed lessons, completed sections, and average score."""
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            # Count completed lessons (progress = 100)
            cur.execute(
                'SELECT COUNT(*) FROM user_lesson_progress WHERE user_id = %s AND progress = 100',
                (user_id,)
            )
            completed_lessons = cur.fetchone()['count']
            
            # Count total completed slides (sections)
            cur.execute(
                'SELECT COUNT(*) FROM user_slide_completion WHERE user_id = %s AND completed = true',
                (user_id,)
            )
            completed_sections = cur.fetchone()['count']
            
            # Calculate average score across all lessons
            cur.execute(
                'SELECT AVG(progress) FROM user_lesson_progress WHERE user_id = %s',
                (user_id,)
            )
            avg_score_result = cur.fetchone()
            average_score = int(avg_score_result['avg'] or 0)
    
    return {
        'completed_lessons': completed_lessons,
        'completed_sections': completed_sections,
        'average_score': average_score
    }


def fetch_slide_resources(slide_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                'SELECT image_id, image_url FROM public.slide_image WHERE slide_id = %s',
                (slide_id,),
            )
            images = cur.fetchall()

            cur.execute(
                'SELECT video_id, video_url FROM public.slide_video WHERE slide_id = %s',
                (slide_id,),
            )
            videos = []
            for row in cur.fetchall():
                row['embed_url'] = get_youtube_embed_url(row['video_url'])
                videos.append(row)

            cur.execute(
                '''
                SELECT q.question_id,
                       q.question,
                       q.result,
                       json_agg(json_build_object(
                           'response_id', r.response_id,
                           'response_text', r.response_text,
                           'is_correct', r.is_correct
                       ) ORDER BY r.response_id) AS responses
                FROM public.slide_question q
                LEFT JOIN public.question_response r ON r.question_id = q.question_id
                WHERE q.slide_id = %s
                GROUP BY q.question_id, q.question, q.result
                ''',
                (slide_id,),
            )
            questions = cur.fetchall()

    assign_correct_answers(questions)
    return images, videos, questions


@app.route('/')
def index():
    user_id = get_user_id()
    stats = get_user_statistics(user_id)
    resp = make_response(render_template('index.html', stats=stats))
    set_user_cookie(resp, user_id)
    return resp


@app.route('/about')
def about():
    user_id = get_user_id()
    resp = make_response(render_template('about.html'))
    set_user_cookie(resp, user_id)
    return resp


@app.route('/lessons')
def lessons():
    user_id = get_user_id()
    lessons_data = fetch_lessons(user_id)
    filter_value = request.args.get('filter', 'all').lower()
    if filter_value not in ('all', 'completed', 'in_progress', 'not_started'):
        filter_value = 'all'
    resp = make_response(render_template('lessons.html', lessons=lessons_data, selected_filter=filter_value))
    set_user_cookie(resp, user_id)
    return resp


@app.route('/lessons/<int:lesson_id>')
def lesson_detail(lesson_id):
    user_id = get_user_id()
    lesson = fetch_lesson(lesson_id, user_id)
    if lesson is None:
        abort(404)
    resp = make_response(render_template('lesson.html', lesson=lesson))
    set_user_cookie(resp, user_id)
    return resp


@app.route('/lessons/<int:lesson_id>/slides/<int:slide_number>')
def lesson_slide(lesson_id, slide_number):
    user_id = get_user_id()
    lesson = fetch_lesson(lesson_id, user_id)
    if lesson is None:
        abort(404)

    slide = fetch_slide(lesson_id, slide_number)
    if slide is None:
        abort(404)

    # Mark current slide as completed if not the last slide
    slide_count = lesson['slide_count'] or 0
    if slide_number < slide_count:
        update_slide_completion(user_id, lesson_id, slide_number, True)
        update_lesson_progress(user_id, lesson_id)

    images, videos, questions = fetch_slide_resources(slide['slide_id'])
    prev_slide = slide_number - 1 if slide_number > 1 else None
    next_slide = slide_number + 1 if slide_number < slide_count else None

    resp = make_response(render_template(
        'lesson_slide.html',
        lesson=lesson,
        slide=slide,
        images=images,
        videos=videos,
        questions=questions,
        prev_slide=prev_slide,
        next_slide=next_slide,
        slide_number=slide_number,
        slide_count=slide_count,
    ))
    set_user_cookie(resp, user_id)
    return resp


@app.route('/lessons/<int:lesson_id>/complete')
def complete_lesson(lesson_id):
    user_id = get_user_id()
    lesson = fetch_lesson(lesson_id, user_id)
    if lesson is None:
        abort(404)
    
    slide_count = lesson['slide_count']
    update_slide_completion(user_id, lesson_id, slide_count, True)
    update_lesson_progress(user_id, lesson_id)
    
    resp = make_response(redirect(url_for('lesson_detail', lesson_id=lesson_id)))
    set_user_cookie(resp, user_id)
    return resp


@app.route('/reset-progress')
def reset_progress():
    user_id = get_user_id()
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute('DELETE FROM user_lesson_progress WHERE user_id = %s', (user_id,))
            cur.execute('DELETE FROM user_slide_completion WHERE user_id = %s', (user_id,))
            conn.commit()
    
    resp = make_response(redirect(url_for('lessons')))
    resp.delete_cookie('user_id')
    return resp


@app.route('/about-me')
def about_me():
    return redirect(url_for('about'))


if __name__ == '__main__':
    app.run()