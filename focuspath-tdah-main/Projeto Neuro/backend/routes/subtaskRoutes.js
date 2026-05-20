const express = require('express');
const router = express.Router({ mergeParams: true });
const subtaskController = require('../controllers/subtaskController');

router.get('/', subtaskController.getSubtasks);
router.post('/', subtaskController.createSubtask);
router.put('/:id', subtaskController.toggleSubtask);
router.delete('/:id', subtaskController.deleteSubtask);

module.exports = router;