import ActivityLog from "../models/activityLogModel.js"
import User from "../models/userModel.js";

export const getLogs = async (req, res)=>{
    try {
        const dateNow = Date.now();
        await ActivityLog.findAll({
            include: [
              {
                model: User,
                required: true
              },
            ],
          }, {
            subQuery: false,
          }).then((response) => {
            return res.json({
                message: "Log berhasil diambil !",
                status: "success",
                data: response
            });
        })
    } catch (error) {
        
    }
}