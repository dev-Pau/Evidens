const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();

async function addNotificationOnCaseApprove(caseId, userId) {

  const timestamp = admin.firestore.FieldValue.serverTimestamp();

  const notificationData = {
    contentId: caseId,
    kind: 201,
    timestamp: timestamp,
    uid: userId,
  };

  const userNotificationsRef = admin
        .firestore()
        .collection('notifications')
        .doc(userId)
        .collection('user-notifications');

  
  const notificationRef = await userNotificationsRef.add(notificationData);
  const notificationId = notificationRef.id;

  await notificationRef.update({ id: notificationId });
  await sendCaseAcceptedNotification(userId);
}

module.exports = {
  addNotificationOnCaseApprove
};


/// Helpers

async function sendCaseAcceptedNotification(userId) {

  const preferencesRef = db.collection('notifications').doc(userId);
  const preferencesSnapshot = await preferencesRef.get();
  const preferences = preferencesSnapshot.data();

  // Stop execution if notifications are disabled for the user
  if (!preferences.enabled) {
      console.log('Notifications disabled', userId);
      return;
  }

  const title = "Evidens";

  const tokenSnapshot = await admin.database().ref(`/tokens/${userId}`).once('value');
  const tokenData = tokenSnapshot.val();

  const code = preferences.code;

  let body = "Your case has been approved";

  switch (code) {
      case "es":
          body = "Tu caso ha sido aprobado";
          break;
      
      case "ca":
          body = "El teu cas ha estat aprovat"
          break;
  }

  const message = {
      notification: {
          title: title,
          body: body
      },
      token: tokenData,
  };

  admin.messaging().send(message);
  functions.logger.log('Notifications sent');
};

