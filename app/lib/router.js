var router = require('express').Router();

const authRouter = require('../router/authRouter');
const userRouter = require('../router/userRouter');

module.exports = router;

router.use(authRouter)
router.use(userRouter)