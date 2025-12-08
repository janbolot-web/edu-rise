/*
  Seed script for Firestore structure:
  Collection: subjects -> doc 'analogy' -> fields { name, stage }
  Subcollection: stages -> doc 'stage-1' -> fields { title, order }
  Subcollection: modules -> docs 'module-1', 'module-2' under stage doc
  Each module has subcollection lessons -> lesson docs

  Usage:
  - Using Firestore emulator (recommended for local dev):
      1) Start emulator: `firebase emulators:start --only firestore` (in project)
      2) Run: `node scripts/seed_firestore.js`
     The script will connect automatically to the emulator if env var FIRESTORE_EMULATOR_HOST is set by the emulator.

  - Using production Firestore (requires service account JSON):
      1) Place service account JSON as `scripts/serviceAccountKey.json`
      2) Run: `node scripts/seed_firestore.js`

  Make sure `firebase-admin` is installed in the workspace or globally:
    npm install firebase-admin
*/

const admin = require('firebase-admin');
const fs = require('fs');

// If a service account key exists at scripts/serviceAccountKey.json and we're not using emulator, use it
const serviceAccountPath = './scripts/serviceAccountKey.json';
if (!process.env.FIRESTORE_EMULATOR_HOST) {
  if (fs.existsSync(serviceAccountPath)) {
    const serviceAccount = require(serviceAccountPath);
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
  } else {
    console.error('No FIRESTORE_EMULATOR_HOST and no serviceAccountKey.json found at scripts/serviceAccountKey.json.');
    console.error('Either run the Firestore emulator or provide a service account JSON.');
    process.exit(1);
  }
} else {
  // If emulator env var is set, initialize default app (connects to emulator)
  admin.initializeApp();
}

const db = admin.firestore();

async function seed() {
  console.log('Seeding Firestore...');

  // Root collection `subjects` with a document `analogy`
  const subjectRef = db.collection('subjects').doc('analogy');
  await subjectRef.set({
    name: 'Аналогия',
    stage: 1,
    description: 'Пример предмета: Аналогия',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // stages subcollection under the subject
  const stageRef = subjectRef.collection('stages').doc('stage-1');
  await stageRef.set({
    title: 'I Этап',
    order: 1,
    summary: 'Первый этап',
  });

  // modules subcollection under stage
  const modulesRef = stageRef.collection('modules');

  const module1 = modulesRef.doc('module-1');
  await module1.set({ title: 'Модуль 1', order: 1, summary: 'Введение' });
  const lessons1 = module1.collection('lessons');
  await lessons1.doc('lesson-1').set({ title: 'Урок 1', order: 1, content: 'Содержание урока 1' });
  await lessons1.doc('lesson-2').set({ title: 'Урок 2', order: 2, content: 'Содержание урока 2' });

  const module2 = modulesRef.doc('module-2');
  await module2.set({ title: 'Модуль 2', order: 2, summary: 'Практика' });
  const lessons2 = module2.collection('lessons');
  await lessons2.doc('lesson-1').set({ title: 'Урок 1', order: 1, content: 'Содержание урока 1' });
  await lessons2.doc('lesson-2').set({ title: 'Урок 2', order: 2, content: 'Содержание урока 2' });

  console.log('Seed finished successfully');
}

seed()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Seed failed:', err);
    process.exit(1);
  });
