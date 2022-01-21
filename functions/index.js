const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');
const cors = require('cors')({origin: true});
var config = require('./config');
admin.initializeApp();

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