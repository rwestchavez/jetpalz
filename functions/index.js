const functions = require("firebase-functions");
const admin = require("firebase-admin");
var serviceAccount = require("./cloud-services.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});



exports.sendNotificationOnRequestChange = functions.firestore
    .document("requests/{requestId}")
    .onUpdate(async (change, context) => {
        console.log("Request update detected");
        const beforeData = change.before.data();
        const afterData = change.after.data();

        // Check if the status has changed
        if (beforeData['status'] !== afterData['status']) {
            let message = "";
            const userId = afterData['requesterId'];

            if (afterData['status'] === "accepted") {
                message = "Your request has been accepted.";
                console.log("Accepted request");

            } else if (afterData['status'] === "rejected") {
                message = "Your request has been rejected.";
                console.log("Rejected request");
            }

            if (message && userId) {
                // Fetch the user document to get the FCM or APNS token and device type
                const userDoc = await admin.firestore().collection("users").doc(userId).get();
                const userData = userDoc.data();

                if (userData) {


                    // Determine the token type and send the notification
                    if (userData["device_type"] === "ios" && userData["apns_token"]) {
                        try {
                            console.log("sending message ios");
                            const response = await admin.messaging().send({

                                token: userData["fcm_token"],
                                notification: {
                                    title: "JetPalz",
                                    body: message
                                },
                                android: {
                                    ttl: 86400000,  // 1 day in milliseconds
                                    notification: {
                                        clickAction: "OPEN_ACTIVITY_1"
                                    }
                                },
                                apns: {
                                    payload: {
                                        aps: {
                                            alert: {
                                                title: "JetPalz",
                                                body: message
                                            },
                                            badge: 1, // Optional: Add badge count if needed
                                            sound: "default" // Optional: Add sound
                                        }
                                    }
                                },
                            });

                            console.log('APNS notification sent successfully:', response);
                        } catch (error) {
                            console.error('Error sending APNS notification:', error);
                        }
                    } else if (userData["device_type"] === "android" && userData["fcm_token"]) {
                        try {
                            const response = await admin.messaging().send({

                                token: userData["fcm_token"],
                                notification: {
                                    title: "JetPalz",
                                    body: message
                                },
                                android: {
                                    ttl: 86400000,  // 1 day in milliseconds
                                    notification: {
                                        clickAction: "OPEN_ACTIVITY_1"
                                    }
                                },
                                apns: {
                                    payload: {
                                        aps: {
                                            alert: {
                                                title: "JetPalz",
                                                body: message
                                            },
                                            badge: 1, // Optional: Add badge count if needed
                                            sound: "default" // Optional: Add sound
                                        }
                                    }
                                },
                            });

                            console.log('FCM notification sent successfully:', response);
                        } catch (error) {
                            console.error('Error sending FCM notification:', error);
                        }
                    }
                }
            }
        }

        return null;
    });

exports.sendNotificationOnRequestCreate = functions.firestore
    .document("requests/{requestId}")
    .onCreate(async (snap, context) => {
        console.log("Request create detected");
        const requestData = snap.data();
        const ventureId = requestData["ventureId"];
        const ventureSnap = await admin.firestore().collection("ventures").doc(ventureId).get();
        const ventureData = ventureSnap.data();
        const creatorRef = ventureData['creator'];
        const creatorId = creatorRef.id;

        if (creatorId) {
            // Fetch the user document to get the FCM or APNS token and device type
            const userDoc = await admin.firestore().collection("users").doc(creatorId).get();
            const userData = userDoc.data();

            if (userData) {



                // Determine the token type and send the notification
                if (userData["device_type"] === "ios" && userData["apns_token"]) {
                    try {
                        console.log("sending message ios")
                        const response = await admin.messaging().send(



                            {

                                token: userData["fcm_token"],
                                notification: {
                                    title: "JetPalz",
                                    body: 'Someone has just requested to join your venture'
                                },
                                android: {
                                    ttl: 86400000,  // 1 day in milliseconds
                                    notification: {
                                        clickAction: "OPEN_ACTIVITY_1"
                                    }
                                },
                                apns: {
                                    payload: {
                                        aps: {
                                            alert: {
                                                title: "JetPalz",
                                                body: 'Someone has just requested to join your venture'
                                            },
                                            badge: 1, // Optional: Add badge count if needed
                                            sound: "default" // Optional: Add sound
                                        }
                                    }
                                },
                            }
                        );

                        console.log('APNS notification sent successfully:', response);
                    } catch (error) {


                        console.error('Error sending APNS notification:', error);
                    }
                } else if (userData["device_type"] === "android" && userData["fcm_token"]) {
                    try {
                        const response = await admin.messaging().send(
                            {
                                token: userData["fcm_token"],
                                notification: {
                                    title: "JetPalz",
                                    body: 'Someone has just requested to join your venture'
                                },
                                android: {
                                    ttl: 86400000,  // 1 day in milliseconds
                                    notification: {
                                        clickAction: "OPEN_ACTIVITY_1"
                                    }
                                },
                                apns: {
                                    headers: {
                                        "apns-priority": "5",
                                    },
                                    payload: {
                                        aps: {
                                            category: "NEW_MESSAGE_CATEGORY"
                                        }
                                    }
                                }
                            });

                        console.log('FCM notification sent successfully:', response);
                    } catch (error) {
                        console.error('Error sending FCM notification:', error);
                    }
                }
            }
        }

        return null;
    });