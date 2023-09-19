import { Sequelize } from "sequelize";

const db = new Sequelize('pos_db', 'root', '', {
    host: "localhost",
    dialect: "mysql"
})

export default db;