const express = require('express');
const router = express.Router({ mergeParams: true });
const subtaskController = require('../controllers/subtaskController');
const auth = require('../middleware/authMiddleware');

router.get('/', auth, subtaskController.getSubtasks);
router.post('/', auth, subtaskController.createSubtask);
router.put('/:id', auth, subtaskController.toggleSubtask);
router.delete('/:id', auth, subtaskController.deleteSubtask);

module.exports = router;