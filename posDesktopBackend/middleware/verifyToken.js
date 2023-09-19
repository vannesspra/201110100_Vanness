import jwt from "jsonwebtoken";

export const verifyToken = (req, res, next) => {
    const authHeader = req.query["authorization"];
    const token = authHeader && authHeader.split(' ')[1];
    console.log("GET TOKEN: " + token);
    if(token == null) return res.sendStatus(401);
    jwt.verify(token, process.env.ACCESS_TOKEN_SECRET, (err, decoded) => {
        if(err) return res.sendStatus(403);
        req.userId = decoded.userId;
        req.name = decoded.name;
        req.userName = decoded.userName;
        req.role = decoded.role;
        next();
    })
}