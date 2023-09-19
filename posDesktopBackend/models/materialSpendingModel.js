import { Sequelize } from "sequelize";
import db from "../config/database.js";
import Material from "./materialModel.js";
import FabricatingMaterial from "./fabricatingMaterialModel.js"


const { DataTypes } = Sequelize;

const MaterialSpending = db.define(
  "materialSpending",
  {
    materialSpendingId: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      allowNull: false,
      autoIncrement: true,
    },
    materialSpendingCode: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    materialSpendingDate: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    materialSpendingQty: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    materialId: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    fabricatingMaterialId: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
  },
  {
    freezeTableName: true,
    timestamps: false,
  }
);

MaterialSpending.belongsTo(Material, {
  foreignKey: "materialId",
});

Material.hasMany(MaterialSpending, {
  foreignKey: "materialId",
});

MaterialSpending.belongsTo(FabricatingMaterial, {
  foreignKey: "fabricatingMaterialId",
});

FabricatingMaterial.hasMany(MaterialSpending, {
  foreignKey: "fabricatingMaterialId",
});

export default MaterialSpending;
