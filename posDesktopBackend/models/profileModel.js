import { Sequelize } from "sequelize";
import db from  "../config/database.js";

const {DataTypes} = Sequelize;

const Profile = db.define('profile', {
    companyId:{
        type: DataTypes.INTEGER,
        primaryKey: true,
        allowNull: false,
        autoIncrement: true
    },
    companyName: {
        type: DataTypes.STRING,
        allowNull: false
    },
    companyAddress: {
        type: DataTypes.STRING,
        allowNull: false
    },
    companyPhoneNumber: {
        type: DataTypes.STRING,
        allowNull: false
    },
    companyWebsite: {
        type: DataTypes.STRING,
        allowNull: false
    },
    companyEmail: {
        type: DataTypes.STRING,
        allowNull: false
    },
    companyContactPerson: {
        type: DataTypes.STRING,
        allowNull: false
    },
    companyContactPersonNumber: {
        type: DataTypes.STRING,
        allowNull: false
    },
}, {
    freezeTableName: true,
    timestamps: false
})

export default Profile;