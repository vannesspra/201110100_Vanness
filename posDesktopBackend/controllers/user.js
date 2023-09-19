import Users from "../models/userModel.js";
import bcrypt from "bcryptjs";
import { createLog } from "../functions/createLog.js";
export const getUsers = async (req, res) => {
  try {
    const users = await Users.findAll();
    res.json(users);
  } catch (error) {
    console.log(error);
  }
};

export const register = async (req, res) => {
  const { name, userName, password, confPassword } = req.body;
  if (password != confPassword)
    return res
      .status(400)
      .json({ msg: "Confirm Password tidak sesuai dengan Password" });
  const salt = await bcrypt.genSalt();
  const hashPassword = await bcrypt.hash(password, salt);

  try {
    await Users.create({
      name: name,
      userName: userName,
      password: hashPassword,
    }).then((response) => {
      res.json({
        msg: "Berhasil register user",
        data: {
          name: response.name,
          userName: response.userName,
        },
      });
    });
  } catch (error) {
    console.log(log);
  }
};
