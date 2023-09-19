import { Sequelize } from "sequelize";
import db from "../config/database.js";
import User from "./userModel.js";

const { DataTypes } = Sequelize;

const ActivityLog = db.define(
  "activityLog",
  {
    logId: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      allowNull: false,
      autoIncrement: true,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    activityType: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    activity: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    activityDate: {
      type: DataTypes.DATE,
      allowNull: false,
    },
  },
  {
    freezeTableName: true,
    timestamps: false,
  }
);

ActivityLog.belongsTo(User, {
    foreignKey: "userId",
});
  
User.hasMany(ActivityLog, {
    foreignKey: "userId",
});

export default ActivityLog;
