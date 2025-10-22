// Usage:
// NODE_SERVICE_ACCOUNT=/path/to/serviceAccount.json node add_embed_course.js
// or set GOOGLE_APPLICATION_CREDENTIALS to service account path.

const admin = require('firebase-admin');
const path = require('path');

async function main() {
  const saPath = process.env.NODE_SERVICE_ACCOUNT || process.env.GOOGLE_APPLICATION_CREDENTIALS;
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

function resolveServiceAccountPath() {
  const envPath = process.env.NODE_SERVICE_ACCOUNT || process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (!envPath) return null;
  // if it's a relative path, resolve it from the script directory
  return path.isAbsolute(envPath) ? envPath : path.resolve(__dirname, envPath);
}

function main() {
  const saPath = resolveServiceAccountPath();

  if (!saPath) {
    console.error('\nService account not provided. Set one of these environment variables and try again:\n');
    console.error('  NODE_SERVICE_ACCOUNT=/absolute/path/to/service-account.json node add_embed_course.js');
    console.error('  or');
    console.error('  export GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/to/service-account.json && node add_embed_course.js\n');
    process.exit(2);
  }

  if (!fs.existsSync(saPath)) {
    console.error(`\nService account file not found at: ${saPath}`);
    console.error('Please make sure the path is correct and the file is accessible.');
    console.error('If the file is on another machine, copy it here or run the script on that machine.');
    process.exit(3);
  }

  let serviceAccount;
  try {
    serviceAccount = JSON.parse(fs.readFileSync(saPath, 'utf8'));
  } catch (err) {
    console.error(`\nFailed to read or parse service account JSON at ${saPath}:`, err.message);
    process.exit(4);
  }

  try {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
  } catch (err) {
    console.error('\nFailed to initialize Firebase Admin SDK:', err.message);
    process.exit(5);
  }

  const db = admin.firestore();

  const id = 'kyrgyz-tili-grammatikasy-' + Date.now();
  const course = {
    id,
    title: 'Кыргыз тили граматикасы',
    description: 'Курс по грамматике кыргызского языка — правила, примеры и упражнения.',
    author: 'Edurise',
    rating: 0,
    price: 0,
    lessonsCount: 0,
    gradientColors: ['#FF7A18', '#AF002D'],
    modules: [],
    type: 'embed',
    embedHtml: '<iframe src="https://docs.google.com/presentation/d/e/2PACX-1vTq3.../pub?start=false&loop=false&delayms=3000" width="960" height="569" frameborder="0" allowfullscreen="true"></iframe>',
    embedUrl: 'https://docs.google.com/presentation/d/e/2PACX-1vTq3.../pub?start=false&loop=false&delayms=3000',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  db.collection('courses').doc(id).set(course)
    .then(() => {
      console.log('Course created with id:', id);
      process.exit(0);
    })
    .catch(err => {
      console.error('Failed to create course:', err.message || err);
      process.exit(1);
    });
}

main();
}

main();
