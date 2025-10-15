import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edurise/features/tests/domain/models/question.dart';
import 'package:edurise/features/tests/domain/models/test.dart';

class TestDataSamples {
  static Future<void> createSampleTests(String teacherId, String teacherName) async {
    final firestore = FirebaseFirestore.instance;

    // Тест 1: Математика - Дроби
    final mathTest = Test(
      id: '',
      title: 'Математика 5 класс - Обыкновенные дроби',
      description: 'Тест на знание обыкновенных дробей, сложение и вычитание дробей с одинаковыми знаменателями',
      subject: 'Математика',
      gradeLevel: 5,
      difficulty: TestDifficulty.easy,
      duration: 15,
      teacherId: teacherId,
      teacherName: teacherName,
      status: TestStatus.published,
      createdAt: DateTime.now(),
      publishedAt: DateTime.now(),
      passingScore: 70,
      tags: ['дроби', 'арифметика', '5 класс'],
      questions: [
        Question(
          id: 'q1',
          text: 'Сколько будет 1/2 + 1/4?',
          type: QuestionType.multipleChoice,
          options: ['1/6', '3/4', '2/6', '1/8'],
          correctAnswer: '3/4',
          explanation: '1/2 = 2/4, поэтому 2/4 + 1/4 = 3/4',
          points: 1,
        ),
        Question(
          id: 'q2',
          text: 'Дробь - это число, состоящее из одной или нескольких частей единицы',
          type: QuestionType.trueFalse,
          options: ['Правда', 'Ложь'],
          correctAnswer: 'Правда',
          explanation: 'Дробь действительно представляет части целого',
          points: 1,
        ),
        Question(
          id: 'q3',
          text: 'Сколько будет 5/8 - 2/8?',
          type: QuestionType.shortAnswer,
          options: [],
          correctAnswer: '3/8',
          explanation: 'При вычитании дробей с одинаковыми знаменателями вычитаем числители: 5-2=3',
          points: 2,
        ),
        Question(
          id: 'q4',
          text: 'Какая дробь больше: 3/5 или 2/5?',
          type: QuestionType.multipleChoice,
          options: ['3/5', '2/5', 'Они равны', 'Нельзя сравнить'],
          correctAnswer: '3/5',
          explanation: 'При одинаковых знаменателях больше та дробь, у которой больше числитель',
          points: 1,
        ),
        Question(
          id: 'q5',
          text: 'Сколько четвертей в одной целой?',
          type: QuestionType.multipleChoice,
          options: ['2', '3', '4', '5'],
          correctAnswer: '4',
          explanation: '1 = 4/4, поэтому в одной целой 4 четверти',
          points: 1,
        ),
      ],
    );

    // Тест 2: Русский язык - Глаголы
    final russianTest = Test(
      id: '',
      title: 'Русский язык - Глаголы',
      description: 'Проверка знаний о глаголах: определение, спряжение, время',
      subject: 'Русский язык',
      gradeLevel: 6,
      difficulty: TestDifficulty.medium,
      duration: 20,
      teacherId: teacherId,
      teacherName: teacherName,
      status: TestStatus.published,
      createdAt: DateTime.now(),
      publishedAt: DateTime.now(),
      passingScore: 70,
      tags: ['глаголы', 'морфология', 'спряжение'],
      questions: [
        Question(
          id: 'q1',
          text: 'Что обозначает глагол?',
          type: QuestionType.multipleChoice,
          options: [
            'Действие или состояние',
            'Предмет',
            'Признак предмета',
            'Количество'
          ],
          correctAnswer: 'Действие или состояние',
          explanation: 'Глагол - это часть речи, которая обозначает действие или состояние',
          points: 1,
        ),
        Question(
          id: 'q2',
          text: 'Глаголы изменяются по временам',
          type: QuestionType.trueFalse,
          options: ['Правда', 'Ложь'],
          correctAnswer: 'Правда',
          explanation: 'Глаголы имеют формы настоящего, прошедшего и будущего времени',
          points: 1,
        ),
        Question(
          id: 'q3',
          text: 'Какое время у глагола "бежал"?',
          type: QuestionType.multipleChoice,
          options: ['Настоящее', 'Прошедшее', 'Будущее'],
          correctAnswer: 'Прошедшее',
          explanation: 'Глагол "бежал" обозначает действие, которое уже произошло',
          points: 1,
        ),
        Question(
          id: 'q4',
          text: 'Сколько спряжений у глаголов в русском языке?',
          type: QuestionType.shortAnswer,
          options: [],
          correctAnswer: '2',
          explanation: 'В русском языке два спряжения глаголов',
          points: 2,
        ),
        Question(
          id: 'q5',
          text: 'Выберите глагол совершенного вида',
          type: QuestionType.multipleChoice,
          options: ['читать', 'прочитать', 'читающий', 'читая'],
          correctAnswer: 'прочитать',
          explanation: 'Совершенный вид отвечает на вопрос "что сделать?"',
          points: 1,
        ),
        Question(
          id: 'q6',
          text: 'Глагол "бежать" относится к 1 спряжению',
          type: QuestionType.trueFalse,
          options: ['Правда', 'Ложь'],
          correctAnswer: 'Ложь',
          explanation: 'Глагол "бежать" - разноспрягаемый',
          points: 2,
        ),
      ],
    );

    // Тест 3: Английский язык - Present Simple
    final englishTest = Test(
      id: '',
      title: 'English - Present Simple Tense',
      description: 'Test your knowledge of Present Simple tense',
      subject: 'Английский язык',
      gradeLevel: 7,
      difficulty: TestDifficulty.medium,
      duration: 25,
      teacherId: teacherId,
      teacherName: teacherName,
      status: TestStatus.published,
      createdAt: DateTime.now(),
      publishedAt: DateTime.now(),
      passingScore: 75,
      tags: ['present simple', 'grammar', 'tenses'],
      questions: [
        Question(
          id: 'q1',
          text: 'I ___ to school every day',
          type: QuestionType.multipleChoice,
          options: ['go', 'goes', 'going', 'went'],
          correctAnswer: 'go',
          explanation: 'С местоимением "I" используется базовая форма глагола',
          points: 1,
        ),
        Question(
          id: 'q2',
          text: 'She ___ English and French',
          type: QuestionType.multipleChoice,
          options: ['speak', 'speaks', 'speaking', 'spoke'],
          correctAnswer: 'speaks',
          explanation: 'С местоимениями he/she/it глагол получает окончание -s',
          points: 1,
        ),
        Question(
          id: 'q3',
          text: 'Present Simple используется для регулярных действий',
          type: QuestionType.trueFalse,
          options: ['True', 'False'],
          correctAnswer: 'True',
          explanation: 'Present Simple описывает регулярные, повторяющиеся действия',
          points: 1,
        ),
        Question(
          id: 'q4',
          text: 'They ___ football on Sundays',
          type: QuestionType.multipleChoice,
          options: ['play', 'plays', 'playing', 'played'],
          correctAnswer: 'play',
          explanation: 'С местоимением "they" используется базовая форма глагола',
          points: 1,
        ),
        Question(
          id: 'q5',
          text: '___ your sister like chocolate?',
          type: QuestionType.multipleChoice,
          options: ['Do', 'Does', 'Is', 'Are'],
          correctAnswer: 'Does',
          explanation: 'В вопросах с he/she/it используется вспомогательный глагол "does"',
          points: 2,
        ),
      ],
    );

    // Тест 4: Физика - Механика
    final physicsTest = Test(
      id: '',
      title: 'Физика 9 класс - Законы Ньютона',
      description: 'Тест на знание трех законов Ньютона и их применение',
      subject: 'Физика',
      gradeLevel: 9,
      difficulty: TestDifficulty.hard,
      duration: 30,
      teacherId: teacherId,
      teacherName: teacherName,
      status: TestStatus.published,
      createdAt: DateTime.now(),
      publishedAt: DateTime.now(),
      passingScore: 80,
      tags: ['механика', 'законы Ньютона', 'динамика'],
      questions: [
        Question(
          id: 'q1',
          text: 'Первый закон Ньютона также называется законом инерции',
          type: QuestionType.trueFalse,
          options: ['Правда', 'Ложь'],
          correctAnswer: 'Правда',
          explanation: 'Первый закон Ньютона описывает инерцию тел',
          points: 1,
        ),
        Question(
          id: 'q2',
          text: 'Формула второго закона Ньютона:',
          type: QuestionType.multipleChoice,
          options: ['F = ma', 'E = mc²', 'P = mv', 'W = Fs'],
          correctAnswer: 'F = ma',
          explanation: 'Сила равна произведению массы на ускорение',
          points: 2,
        ),
        Question(
          id: 'q3',
          text: 'Сколько законов Ньютона существует?',
          type: QuestionType.shortAnswer,
          options: [],
          correctAnswer: '3',
          explanation: 'Ньютон сформулировал три основных закона механики',
          points: 1,
        ),
        Question(
          id: 'q4',
          text: 'Третий закон Ньютона гласит: "Действие равно противодействию"',
          type: QuestionType.trueFalse,
          options: ['Правда', 'Ложь'],
          correctAnswer: 'Правда',
          explanation: 'Силы взаимодействия двух тел равны по величине и противоположны по направлению',
          points: 1,
        ),
        Question(
          id: 'q5',
          text: 'Какое ускорение получит тело массой 2 кг под действием силы 10 Н?',
          type: QuestionType.multipleChoice,
          options: ['5 м/с²', '20 м/с²', '0.2 м/с²', '2 м/с²'],
          correctAnswer: '5 м/с²',
          explanation: 'a = F/m = 10/2 = 5 м/с²',
          points: 3,
        ),
      ],
    );

    // Сохраняем тесты в Firestore
    try {
      await firestore.collection('tests').add(mathTest.toJson());
      print('✅ Создан тест: Математика - Дроби');
      
      await firestore.collection('tests').add(russianTest.toJson());
      print('✅ Создан тест: Русский язык - Глаголы');
      
      await firestore.collection('tests').add(englishTest.toJson());
      print('✅ Создан тест: English - Present Simple');
      
      await firestore.collection('tests').add(physicsTest.toJson());
      print('✅ Создан тест: Физика - Законы Ньютона');
      
      print('\n🎉 Все тестовые тесты успешно созданы!');
    } catch (e) {
      print('❌ Ошибка при создании тестов: $e');
    }
  }

  // JSON данные для ручного добавления в Firestore Console
  static Map<String, dynamic> getMathTestJson() {
    return {
      "title": "Математика 5 класс - Обыкновенные дроби",
      "description": "Тест на знание обыкновенных дробей, сложение и вычитание дробей",
      "subject": "Математика",
      "gradeLevel": 5,
      "difficulty": "easy",
      "duration": 15,
      "teacherId": "teacher123",
      "teacherName": "Иванова Мария Петровна",
      "status": "published",
      "createdAt": Timestamp.now(),
      "publishedAt": Timestamp.now(),
      "totalPoints": 6,
      "passingScore": 70,
      "tags": ["дроби", "арифметика", "5 класс"],
      "attempts": 0,
      "averageScore": 0.0,
      "questions": [
        {
          "id": "q1",
          "text": "Сколько будет 1/2 + 1/4?",
          "type": "multipleChoice",
          "options": ["1/6", "3/4", "2/6", "1/8"],
          "correctAnswer": "3/4",
          "explanation": "1/2 = 2/4, поэтому 2/4 + 1/4 = 3/4",
          "points": 1
        },
        {
          "id": "q2",
          "text": "Дробь - это число, состоящее из одной или нескольких частей единицы",
          "type": "trueFalse",
          "options": ["Правда", "Ложь"],
          "correctAnswer": "Правда",
          "explanation": "Дробь действительно представляет части целого",
          "points": 1
        },
        {
          "id": "q3",
          "text": "Сколько будет 5/8 - 2/8?",
          "type": "shortAnswer",
          "options": [],
          "correctAnswer": "3/8",
          "explanation": "При вычитании дробей с одинаковыми знаменателями вычитаем числители",
          "points": 2
        },
        {
          "id": "q4",
          "text": "Какая дробь больше: 3/5 или 2/5?",
          "type": "multipleChoice",
          "options": ["3/5", "2/5", "Они равны", "Нельзя сравнить"],
          "correctAnswer": "3/5",
          "explanation": "При одинаковых знаменателях больше та дробь, у которой больше числитель",
          "points": 1
        },
        {
          "id": "q5",
          "text": "Сколько четвертей в одной целой?",
          "type": "multipleChoice",
          "options": ["2", "3", "4", "5"],
          "correctAnswer": "4",
          "explanation": "1 = 4/4, поэтому в одной целой 4 четверти",
          "points": 1
        }
      ]
    };
  }
}
