import ExtraDiscount from "../models/extraDiscountModel.js";
import { Op } from "sequelize";

export const updateExtraDiscount = async (req, res) =>{
    try{
        var _extraDiscountId = parseInt(req.query["extraDiscount"]);
        await ExtraDiscount.update(
            {
                amountPaid: req.body.amountPaid,
                discount: req.body.discount
            }, {
                where: {
                    extraDiscountId: _extraDiscountId
                }
            }
        ).then((response)=>{
            return res.json({
                message: "Data extra diskon berhasil diubah !",
                status: "success",
              });
        })
    } catch (error){

    }
}