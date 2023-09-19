import User from "../models/userModel.js";
import jwt from "jsonwebtoken";
import {
    getUsers
} from "./user.js";
import {
    Op, where
  } from "sequelize";

import { createLog } from "../functions/createLog.js";
export const createUser = async (req, res) => {
    try {
        for (var [key, value] of Object.entries(req.body)) {
            if (req.body[key] == "") {
                req.body[key] = null;
            }
        }
        await User.create({
            name: req.body.name,
            userName: req.body.userName,
            password: req.body.password,
            role: req.body.role,
            isDeleted: 0
        }).then((response) => {
            return res.json({
                message: "Akun baru berhasil dibuat",
                status: "success",
            });
        });
    } catch (error) {
        var message = "";
        var field = "";

        // Field checking
        if (error.errors[0].path == "name") {
            field = "Nama Lengkap";
        } else if (error.errors[0].path == "userName") {
            field = "Nama Pengguna";
        } else if (error.errors[0].path == "password") {
            field = "Password";
        } else if (error.errors[0].path == "role") {
            field = "Role";
        }

        // Set a message
        if (error.errors[0].type == "unique violation") {
            message = field + " " + error.errors[0].value + " sudah terpakai";
        } else if (error.errors[0].type == "notNull Violation") {
            message = field + " tidak boleh kosong";
        }
        return res.json({
            message: message,
            status: "error"
        });
    }
};

export const updateUser = async (req, res) => {
    try {
        var _userId = parseInt(req.query["userId"]);
        for (var [key, value] of Object.entries(req.body)) {
            if (req.body[key] == "") {
                req.body[key] = null;
            }
        }
        await User.update({
            name: req.body.name,
            userName: req.body.userName,
            password: req.body.password,
            role: req.body.role,
        }, {
            where: {
                userId: _userId
            }
        }).then((response) => {
            createLog(req.userId, "Akun", "Edit")
            return res.json({
                message: "Akun berhasil diupdate !",
                status: "success",
            });
        });
    } catch (error) {
        var message = "";
        var field = "";

        // Field checking
        if (error.errors[0].path == "name") {
            field = "Nama Lengkap";
        } else if (error.errors[0].path == "userName") {
            field = "Nama Pengguna";
        } else if (error.errors[0].path == "password") {
            field = "Password";
        } else if (error.errors[0].path == "role") {
            field = "Role";
        }

        // Set a message
        if (error.errors[0].type == "unique violation") {
            message = field + " " + error.errors[0].value + " sudah terpakai";
        } else if (error.errors[0].type == "notNull Violation") {
            message = field + " tidak boleh kosong";
        }
        return res.json({
            message: message,
            status: "error"
        });
    }
};

export const softDeleteUser = async (req, res) => {
    try {
        var _userId = parseInt(req.query["userId"]);
        
        await User.update({
            isDeleted : 1,
        }, {
            where: {
                userId: _userId
            }
        }).then((response) => {
            createLog(req.userId, "Akun", "Delete")
            return res.json({
                message: "Akun berhasil dihapus !",
                status: "success",
            });
        });
    } catch (error) {
        return res.json({
          message: error.message,
          status: "error",
        });
      }
};

export const getUserAccounts = async (req, res) => {
    try {
        2;
        await User.findAll({where: {
            isDeleted: {
              [Op.is]: false,
            }
          }}).then((response) => {
            if (response.length > 0) {
                return res.json({
                    message: "Data semua Akun berhasil diambil",
                    status: "success",
                    data: response,
                });
            } else {
                return res.json({
                    message: "Tidak ada data Akun",
                    status: "success",
                    data: [],
                });
            }
        });
    } catch (error) {
        return res.json({
            message: error.message,
            status: "error",
            data: []
        });
    }
};

export const login = async (req, res) => {
    try {
        const user = await User.findAll({
            where: {
                userName: req.body.userName
            }
        })

        console.log(user);

        if (req.body.password != user[0].password) return res.json({
            message: "Password salah!",
            status: "error",
            type: "password",
            data: {
                "accessToken": "",
                "refreshToken": ""
            }
        });

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
        const refreshToken = jwt.sign({
            userId,
            name,
            userName,
            role
        }, process.env.REFRESH_TOKEN_SECRET, {
            expiresIn: '1d'
        });
        await User.update({
            refresh_token: refreshToken
        }, {
            where: {
                userid: userId
            }
        })

        res.cookie('refreshToken', refreshToken, {
            httpOnly: true,
            maxAge: 24 * 60 * 60 * 1000
        })

        res.json({
            message: "Login Berhasil",
            status: "success",
            data: {
                "accessToken": accessToken,
                "refreshToken": refreshToken
            }
        })
    } catch (error) {
        console.log(error);
        return res.json({
            message: "User name tidak ditemukan!",
            status: "error",
            type: "auth",
            data: {
                "accessToken": "",
                "refreshToken": ""
            }
        });
    }
}

export const logout = async (req, res) => {
    const refreshToken = req.cookies.refreshToken;
    if (!refreshToken) return res.sendStatus(204);
    const user = await User.findAll({
        where: {
            refresh_token: refreshToken
        }
    })
    if (!user[0]) return res.sendStatus(204);
    const _userId = user[0].userId;
    await User.update({
        refresh_token: null
    }, {
        where: {
            userId: _userId
        }
    });
    res.clearCookie('refreshToken');
    return res.sendStatus(200);
}
