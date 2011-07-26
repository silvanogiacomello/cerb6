<?php
class Event_TaskMacro extends AbstractEvent_Task {
	const ID = 'event.macro.task';
	
	function __construct() {
		$this->_event_id = self::ID;
	}
	
	static function trigger($trigger_id, $task_id) {
		$events = DevblocksPlatform::getEventService();
		$events->trigger(
	        new Model_DevblocksEvent(
	            self::ID,
                array(
                    'task_id' => $task_id,
                	'_whisper' => array(
                		'_trigger_id' => array($trigger_id),
                	),
                )
            )
		);
	}
};