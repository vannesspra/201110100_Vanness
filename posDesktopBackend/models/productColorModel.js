import { Sequelize } from "sequelize";
import db from "../config/database.js";
import Product from "./productModel.js";
import Color from "./colorModel.js";
const { DataTypes } = Sequelize;

const ProductColor = db.define(
  "productColor",
  {
    productId: {
      type: DataTypes.INTEGER,
    },

    colorId: {
      type: DataTypes.INTEGER,
    },
  },
  {
    freezeTableName: true,
  }
);

// ProductColor.removeAttribute('id');

Product.belongsToMany(Color, {
  through: ProductColor,
  foreignKey: "productId",
});

Color.belongsToMany(Product, {
  through: ProductColor,
  foreignKey: "colorId",
});

ProductColor.belongsTo(Product, {
  foreignKey: "productId",
});

ProductColor.belongsTo(Color, {
  foreignKey: "colorId",
});

Color.hasMany(ProductColor, {
  foreignKey: "colorId",
  onDelete: "cascade",
  onUpdate: "cascade",
});

Product.hasMany(ProductColor, {
  foreignKey: "productId",
  onDelete: "cascade",
  onUpdate: "cascade",
});

export default ProductColor;
