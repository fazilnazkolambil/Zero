const {onSchedule} = require("firebase-functions/v2/scheduler");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

exports.resetWeeklyTrips = onSchedule(
  {
    schedule: "0 4 * * 1",
    timeZone: "Asia/Kolkata",
  },
  async (event) => {
    console.log("Auto resetting weekly trips...");

    try {
      const orgsSnapshot = await db.collection("organisations").get();

      for (const orgDoc of orgsSnapshot.docs) {
        const orgId = orgDoc.id;

        // Reset drivers' weeklyTrips
        const driversSnapshot = await db
          .collection("organisations")
          .doc(orgId)
          .collection("drivers")
          .get();

        for (const driverDoc of driversSnapshot.docs) {
          await driverDoc.ref.update({ 'weekly_trips': 0,'weekly_shifts':0 });
        }

        // Reset vehicles' weeklyTrips
        const vehiclesSnapshot = await db
          .collection("organisations")
          .doc(orgId)
          .collection("vehicles")
          .get();

        for (const vehicleDoc of vehiclesSnapshot.docs) {
          await vehicleDoc.ref.update({ 'weekly_trips': 0 });
        }
      }

      console.log("✅ Weekly trips reset for all organisations.");
    } catch (error) {
      console.error("❌ Error resetting weekly trips:", error);
    }
  }
);

