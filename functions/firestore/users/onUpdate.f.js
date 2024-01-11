const functions = require('firebase-functions');
const admin = require('firebase-admin');
var client = require('../../config');

 /*
---------------------
enum UserPhase: Int, Codable {
    case category, details, identity, pending, review, verified, deactivate, ban
}
---------------------
 */

exports.firestoreUsersOnUpdate = functions.firestore.document('users/{userId}').onUpdate(async (change, context) => {
    const newUser = change.after.data();
    const previousUser = change.before.data();

    const userId = context.params.userId;

    if (newUser.phase === 5 && previousUser.phase !== 5) {
        // User gets verified; Add User to Typesense
        const name = newUser.firstName + " " + newUser.lastName
        const discipline = newUser.discipline

        document = { userId, name, discipline }
        console.log('User added to Typesense', userId);
        return client.collections('users').documents().create(document)

    } else if (newUser.phase === 6 || newUser.phase === 7) {
        // User gets banned or deactivate his/her account; Remove user from Typesense
        console.log('User removed from Typesense', userId);
        return client.collections('users').documents(userId).delete()
    } else if (newUser.phase === 5) {
        // User is; and was verified; Update his/her values from Typesense
        const name = newUser.firstName + " " + newUser.lastName
        document = { userId, name }
        console.log('User updated from Typesense', userId);
        return client.collections('users').documents(userId).update(document)
    }

    console.log('User changes did not affect to Typesense', userId);
});
