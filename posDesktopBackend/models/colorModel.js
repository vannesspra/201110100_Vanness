import { Sequelize } from "sequelize";
import db from "../config/database.js";

const { DataTypes } = Sequelize;

const Color = db.define(
  "color",
  {
    colorId: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      allowNull: false,
      autoIncrement: true,
    },
    colorCode: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    colorName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    colorDesc: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    isDeleted: {
      type: DataTypes.BOOLEAN,
      allowNull:false
    }
  },
  {
    freezeTableName: true,
    timestamps: false,
  }
);

export default Color;
