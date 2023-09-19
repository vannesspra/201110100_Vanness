import User from "../models/userModel.js";
import jwt from "jsonwebtoken";

export const refreshToken = async (req, res) => {
    try {
        // const refreshToken = req.cookies.refreshToken;
        const authHeader = req.query["authorization"];
        const refreshToken = authHeader && authHeader.split(' ')[1];
        if (!refreshToken) return res.sendStatus(401);
        const user = await User.findAll({
            where: {
                refresh_token: refreshToken
            }
        })
        if (!user[0]) return res.sendStatus(403);
        jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET, (err, decoded) => {
            if (err) return res.sendStatus(403)
            const userId = user[0].userId;
            const name = user[0].name;
            const userName = user[0].userName;
            const role = user[0].role;
            const accessToken = jwt.sign({
                userId,
                name,
                userName,
                role
            }, process.env.ACCESS_TOKEN_SECRET, {
                expiresIn: '20s'
            });
            res.json({
                message: "Token refreshed",
                status: "success",
                data: {
                    "accessToken": accessToken
                }
            });
        })
    } catch (error) {
        console.log(error)
    }
}