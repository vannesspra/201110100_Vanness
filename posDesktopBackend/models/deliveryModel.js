import { Sequelize } from "sequelize";
import db from "../config/database.js";

const { DataTypes } = Sequelize;

const Delivery = db.define(
  "delivery",
  {
    deliveryId: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      allowNull: false,
      autoIncrement: true,
    },
    deliveryCode: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },

    deliveryDate: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    carPlatNumber: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    senderName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    deliveryDesc: {
      type: DataTypes.STRING,
      allowNull: true,
    },
  },
  {
    freezeTableName: true,
    timestamps: false,
  }
);

export default Delivery;
