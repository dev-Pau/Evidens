const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');
const cors = require('cors')({origin: true});
var config = require('./config');
admin.initializeApp();

const algoliasearch = require('algoliasearch');
const { object } = require('firebase-functions/v1/storage');
const algolia = algoliasearch("1CZMK6HJ7G", "c8cf46cb26959992339983f875a4343e");


const gmailEmail = config.user;
const gmailPassword = config.pass;

const mailTransport = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: gmailEmail,
      pass: gmailPassword,
    },
  });

const APP_NAME = 'EVIDENS';

exports.sendWelcomeEmail = functions.auth.user().onCreate((user) => {
    // [END onCreateTrigger]
      // [START eventAttributes]
      const email = user.email; // The email of the user.
      const displayName = user.displayName; // The display name of the user.
      // [END eventAttributes]
    
      return sendWelcomeEmail(email, displayName);
    });

  // Sends a welcome email to the given user.
async function sendWelcomeEmail(email, displayName) {
    const mailOptions = {
      from: `${APP_NAME} <noreply@firebase.com>`,
      to: email,
    };
  
    // The user subscribed to the newsletter.
    mailOptions.subject = `Welcome to ${APP_NAME}!`;
    mailOptions.text = `Hey ${displayName || ''}! Welcome to ${APP_NAME}. I hope you will enjoy our service.`;
    await mailTransport.sendMail(mailOptions);
    functions.logger.log('New welcome email sent to:', email);
    return null;
  }


  

// Delete Post
exports.postOnDelete = functions.firestore.document('posts/{uid}').onDelete((snap, context) => {
  const postID = snap.id




})

// Send notification
exports.sendNotification = functions.firestore.document('notifications/{uid}/user-notifications').onCreate((snap, context) =>  {
  const userId = context.params.userId
  const token = admin.database().ref(`/tokens/${userId}`).once('value');

  const payload = {
    token: token,
      notification: {
          title: 'cloud function demo',
          body: 'message'
      },
      data: {
          body: 'message',
      }
  };


})

// Algoliasearch

exports.postOnCreate = functions.firestore.document('posts/{uid}').onCreate((snap, context) => {
  const postIndex = algolia.initIndex('posts_search');
  const data = snap.data();
  const objectID = snap.id;

  let postData = {
    'objectID': objectID,
    'post': data.post
  }

  return postIndex.saveObject(postData)
})

exports.caseOnCreate = functions.firestore.document('cases/{uid}').onCreate((snap, context) => {
  const caseIndex = algolia.initIndex('cases_search');
  const data = snap.data();
  const objectID = snap.id;

  let caseData = {
    'objectID': objectID,
    'title': data.title,
    'description': data.description
  }

  return caseIndex.saveObject(caseData)
})

exports.userOnUpdate = functions.firestore.document('users/{uid}').onUpdate((change, context) => {
  const usersIndex = algolia.initIndex('users_search');
  // If the user hasn't been deleted
  if (change.after.exists) {
    // Get the data updated for the user
    newUserData = change.after.data();

    // Check if the user is verified, otherwise don't upload to Algolia
    if (newUserData.phase == 4) {
      const objectID = change.after.id;
      let userData = {
        'objectID': objectID,
        'firstName': newUserData.firstName,
        'lastName': newUserData.lastName,
        'category': newUserData.category,
        'profession': newUserData.profession,
        'speciality': newUserData.speciality,
        'profileImageUrl': newUserData.profileImageUrl
      }

      return usersIndex.saveObject(userData)
    }
  }
})

