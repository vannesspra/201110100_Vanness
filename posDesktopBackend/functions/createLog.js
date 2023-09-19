import ActivityLog from "../models/activityLogModel.js"

export const createLog = async function(userId, activityType, activity){
    try {
        console.log("HALO USER : "+userId)
        const dateNow = Date.now();
        await ActivityLog.create({
            userId: userId,
            activityType: activityType,
            activity: activity,
            activityDate: dateNow,
        }).then((response) => {
            return res.json({
                message: "Log berhasil dibuat !",
                status: "success",
            });
        })
    } catch (error) {
        
    }
}