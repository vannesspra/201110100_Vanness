import { Sequelize } from "sequelize";
import db from "../config/database.js";

const { DataTypes } = Sequelize;

const Type = db.define(
  "type",
  {
    typeId: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      allowNull: false,
      autoIncrement: true,
    },
    typeCode: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    typeName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    typeDesc: {
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

export default Type;
