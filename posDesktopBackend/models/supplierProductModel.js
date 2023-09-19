import { Sequelize } from "sequelize";
import db from "../config/database.js";
import FabricatingMaterial from "./fabricatingMaterialModel.js";
import Product from "./productModel.js";
import Material from "./materialModel.js";
import Supplier from "./supplierModel.js"

const { DataTypes } = Sequelize;

const SupplierProduct = db.define(
  "supplierProduct",
  {
    supplierProductId: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      allowNull: false,
      autoIncrement: true,
    },
    supplierId: {
        type: DataTypes.INTEGER,
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
    productId: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
  },
  {
    freezeTableName: true,
    timestamps: false,
  }
);

SupplierProduct.belongsTo(Supplier, {
  foreignKey: "supplierId",
});

Supplier.hasMany(SupplierProduct, {
  foreignKey: "supplierId",
});

SupplierProduct.belongsTo(Product, {
  foreignKey: "productId",
});
  
Product.hasMany(SupplierProduct, {
  foreignKey: "productId",
});

SupplierProduct.belongsTo(Material, {
  foreignKey: "materialId",
});
  
Material.hasMany(SupplierProduct, {
  foreignKey: "materialId",
});

SupplierProduct.belongsTo(FabricatingMaterial, {
  foreignKey: "fabricatingMaterialId",
});
  
FabricatingMaterial.hasMany(SupplierProduct, {
  foreignKey: "fabricatingMaterialId",
});

export default SupplierProduct;
