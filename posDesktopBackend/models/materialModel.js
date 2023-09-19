import { Sequelize } from "sequelize";
import db from "../config/database.js";
import Color from "./colorModel.js";

const { DataTypes } = Sequelize;

const Material = db.define(
    "material", {
        materialId: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            allowNull: false,
            autoIncrement: true,
        },
        materialCode: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,
        },
        materialName: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        colorId: {
            type: DataTypes.INTEGER,
            allowNull: true,
        },
        materialUnit: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        materialMinimumStock: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        materialQty: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        materialPrice: {
            type: DataTypes.STRING,
            allowNull: false,
          },
        isDeleted: {
            type: DataTypes.BOOLEAN,
            allowNull: false
        },
    }, {
        freezeTableName: true,
        timestamps: false,
    }
);

Material.belongsTo(Color, {
    foreignKey: "colorId",
});

Color.hasMany(Material, {
    foreignKey: "colorId",
});

export default Material;