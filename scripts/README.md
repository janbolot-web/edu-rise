add_embed_course.js — скрипт для добавления embed-курса в Firestore

Требования:
- Node.js
- service account JSON с правами записи в Firestore

Запуск:

1) Установите зависимости:
   npm install firebase-admin

2) Запустите скрипт, указав путь к service account:

   NODE_SERVICE_ACCOUNT=/path/to/serviceAccount.json node add_embed_course.js

Или установите переменную окружения GOOGLE_APPLICATION_CREDENTIALS:

   export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccount.json
   node add_embed_course.js

Скрипт создаст документ в коллекции `courses` с полем `type: 'embed'` и `embedHtml`/`embedUrl`.
