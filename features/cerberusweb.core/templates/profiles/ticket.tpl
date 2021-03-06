{$page_context = CerberusContexts::CONTEXT_TICKET}
{$page_context_id = $ticket->id}

<div style="float:left">
	<h1>{$ticket->subject}</h1>
</div>

<div style="float:right">
	{$ctx = Extension_DevblocksContext::get($page_context)}
	{include file="devblocks:cerberusweb.core::search/quick_search.tpl" view=$ctx->getSearchView() return_url="{devblocks_url}c=search&context={$ctx->manifest->params.alias}{/devblocks_url}" reset=true}
</div>

<div style="clear:both;"></div>

{assign var=ticket_group_id value=$ticket->group_id}
{assign var=ticket_group value=$groups.$ticket_group_id}
{assign var=ticket_bucket_id value=$ticket->bucket_id}
{assign var=ticket_group_bucket_set value=$group_buckets.$ticket_group_id}
{assign var=ticket_bucket value=$ticket_group_bucket_set.$ticket_bucket_id}

<fieldset class="properties">
	<legend>{'common.conversation'|devblocks_translate|capitalize}</legend>

	{foreach from=$properties item=v key=k name=props}
		<div class="property">
			{if $k == 'mask'}
				<b>{$translate->_('ticket.mask')|capitalize}:</b>
				{$ticket->mask} 
				(#{$ticket->id})
			{elseif $k == 'status'}
				<b>{$translate->_('ticket.status')|capitalize}:</b>
				{if $ticket->is_deleted}
					<span style="font-weight:bold;color:rgb(150,0,0);">{$translate->_('status.deleted')}</span>
				{elseif $ticket->is_closed}
					<span style="font-weight:bold;color:rgb(50,115,185);">{$translate->_('status.closed')}</span>
					{if !empty($ticket->reopen_at)}
						(opens in <abbr title="{$ticket->reopen_at|devblocks_date}">{$ticket->reopen_at|devblocks_prettytime}</abbr>)
					{/if}
				{elseif $ticket->is_waiting}
					<span style="font-weight:bold;color:rgb(50,115,185);">{$translate->_('status.waiting')}</span>
					{if !empty($ticket->reopen_at)}
						(opens in <abbr title="{$ticket->reopen_at|devblocks_date}">{$ticket->reopen_at|devblocks_prettytime}</abbr>)
					{/if}
				{else}
					{$translate->_('status.open')}
				{/if} 
			{elseif $k == 'org'}
				{$ticket_org = $ticket->getOrg()}
				<b>{'contact_org.name'|devblocks_translate|capitalize}:</b>
				{if !empty($ticket_org)}
				<a href="javascript:;" onclick="genericAjaxPopup('peek','c=internal&a=showPeekPopup&context={CerberusContexts::CONTEXT_ORG}&context_id={$ticket->org_id}',null,false,'500');">{$ticket_org->name}</a>
				{/if}
			{elseif $k == 'bucket'}
				<b>{$translate->_('common.bucket')|capitalize}:</b>
				[{$groups.$ticket_group_id->name}]  
				{if !empty($ticket_bucket_id)}
					{$ticket_bucket->name}
				{else}
					{$translate->_('common.inbox')|capitalize}
				{/if}
			{elseif $k == 'owner'}
				{if !empty($ticket->owner_id) && isset($workers.{$ticket->owner_id})}
					{$owner = $workers.{$ticket->owner_id}}
					<b>{$translate->_('common.owner')|capitalize}:</b>
					<a href="{devblocks_url}c=profiles&p=worker&id={$owner->id}-{$owner->getName()|devblocks_permalink}{/devblocks_url}" target="_blank">{$owner->getName()}</a>
				{else}
					<b>{$translate->_('common.owner')|capitalize}:</b>
					{'common.nobody'|devblocks_translate|lower}
				{/if}
			{else}
				{include file="devblocks:cerberusweb.core::internal/custom_fields/profile_cell_renderer.tpl"}
			{/if}
		</div>
		{if $smarty.foreach.props.iteration % 3 == 0 && !$smarty.foreach.props.last}
			<br clear="all">
		{/if}
	{/foreach}
	<br clear="all">
	
	<a style="color:black;font-weight:bold;" href="javascript:;" id="aRecipients" onclick="genericAjaxPopup('peek','c=display&a=showRequestersPanel&ticket_id={$ticket->id}',null,true,'500');">{'ticket.requesters'|devblocks_translate|capitalize}</a>:
	<span id="displayTicketRequesterBubbles">
		{include file="devblocks:cerberusweb.core::display/rpc/requester_list.tpl" ticket_id=$ticket->id}
	</span>
	<br clear="all">

	<form class="toolbar" action="{devblocks_url}{/devblocks_url}" method="post" style="margin-top:5px;margin-bottom:5px;">
		<input type="hidden" name="c" value="display">
		<input type="hidden" name="a" value="updateProperties">
		<input type="hidden" name="id" value="{$ticket->id}">
		<input type="hidden" name="closed" value="{if $ticket->is_closed}1{else}0{/if}">
		<input type="hidden" name="deleted" value="{if $ticket->is_deleted}1{else}0{/if}">
		<input type="hidden" name="spam" value="0">
		
		<span id="spanWatcherToolbar">
		{$object_watchers = DAO_ContextLink::getContextLinks($page_context, array($page_context_id), CerberusContexts::CONTEXT_WORKER)}
		{include file="devblocks:cerberusweb.core::internal/watchers/context_follow_button.tpl" context=$page_context context_id=$page_context_id full=true}
		</span>
		
		<!-- Macros -->
		{devblocks_url assign=return_url full=true}c=profiles&type=ticket&id={$ticket->mask}{/devblocks_url}
		{include file="devblocks:cerberusweb.core::internal/macros/display/button.tpl" context=$page_context context_id=$page_context_id macros=$macros return_url=$return_url}		
		
		<!-- Edit -->		
		<button type="button" id="btnDisplayTicketEdit" title="{'common.edit'|devblocks_translate|capitalize} (E)">&nbsp;<span class="cerb-sprite2 sprite-gear"></span>&nbsp;</button>
		
		{if !$ticket->is_deleted}
			{if $ticket->is_closed}
				<button type="button" title="{'common.reopen'|devblocks_translate|capitalize}" onclick="this.form.closed.value='0';this.form.submit();">&nbsp;<span class="cerb-sprite sprite-folder_out">&nbsp;</span></button>
			{else}
				{if $active_worker->hasPriv('core.ticket.actions.close')}<button title="{'display.shortcut.close'|devblocks_translate|capitalize}" id="btnClose" type="button" onclick="this.form.closed.value=1;this.form.submit();">&nbsp;<span class="cerb-sprite2 sprite-tick-circle"></span>&nbsp;</button>{/if}
			{/if}
			
			{if empty($ticket->spam_training)}
				{if $active_worker->hasPriv('core.ticket.actions.spam')}<button title="{'display.shortcut.spam'|devblocks_translate|capitalize}" id="btnSpam" type="button" onclick="this.form.spam.value='1';this.form.submit();">&nbsp;<span class="cerb-sprite sprite-spam"></span>&nbsp;</button>{/if}
			{/if}
		{/if}
		
		{if $ticket->is_deleted}
			<button type="button" title="{'common.undelete'|devblocks_translate|capitalize}" onclick="this.form.deleted.value='0';this.form.closed.value=0;this.form.submit();">&nbsp;<span class="cerb-sprite2 sprite-cross-circle-gray"></span>&nbsp;</button>
		{else}
			{if $active_worker->hasPriv('core.ticket.actions.delete')}<button title="{'display.shortcut.delete'|devblocks_translate}" id="btnDelete" type="button" onclick="this.form.deleted.value=1;this.form.closed.value=1;this.form.submit();">&nbsp;<span class="cerb-sprite2 sprite-cross-circle"></span>&nbsp;</button>{/if}
		{/if}
		
		{if $active_worker->hasPriv('core.ticket.view.actions.merge')}<button id="btnMerge" type="button" onclick="genericAjaxPopup('peek','c=display&a=showMergePanel&ticket_id={$ticket->id}',null,false,'500');" title="{'mail.merge'|devblocks_translate|capitalize}">&nbsp;<span class="cerb-sprite2 sprite-arrow-merge-090-left"></span>&nbsp;</button>{/if}
		
	   	<button id="btnPrint" title="{'display.shortcut.print'|devblocks_translate}" type="button" onclick="document.frmPrint.action='{devblocks_url}c=print&a=ticket&id={$ticket->mask}{/devblocks_url}';document.frmPrint.submit();">&nbsp;<span class="cerb-sprite sprite-printer"></span>&nbsp;</button>
	   	<button type="button" title="{'display.shortcut.refresh'|devblocks_translate}" onclick="document.location='{devblocks_url}c=profiles&type=ticket&id={$ticket->mask}{/devblocks_url}';">&nbsp;<span class="cerb-sprite sprite-refresh"></span>&nbsp;</button>
	</form>
	
	<form action="{devblocks_url}{/devblocks_url}" method="post" name="frmPrint" id="frmPrint" target="_blank" style="display:none;"></form>
					
	{if $pref_keyboard_shortcuts}
	<small>
		{$translate->_('common.keyboard')|lower}:
		(<b>e</b>) {'common.edit'|devblocks_translate|lower} 
		(<b>i</b>) {'ticket.requesters'|devblocks_translate|lower} 
		(<b>w</b>) {$translate->_('common.watch')|lower}  
		{if $active_worker->hasPriv('core.display.actions.comment')}(<b>o</b>) {$translate->_('common.comment')} {/if}
		{if !empty($macros)}(<b>m</b>) {'common.macros'|devblocks_translate|lower} {/if}
		{if !$ticket->is_closed && $active_worker->hasPriv('core.ticket.actions.close')}(<b>c</b>) {$translate->_('common.close')|lower} {/if}
		{if !$ticket->spam_trained && $active_worker->hasPriv('core.ticket.actions.spam')}(<b>s</b>) {$translate->_('common.spam')|lower} {/if}
		{if !$ticket->is_deleted && $active_worker->hasPriv('core.ticket.actions.delete')}(<b>x</b>) {$translate->_('common.delete')|lower} {/if}
		{if empty($ticket->owner_id)}(<b>t</b>) {$translate->_('common.assign')|lower} {/if}
		{if !empty($ticket->owner_id)}(<b>u</b>) {$translate->_('common.unassign')|lower} {/if}
		{if !$expand_all}(<b>a</b>) {$translate->_('display.button.read_all')|lower} {/if} 
		{if $active_worker->hasPriv('core.display.actions.reply')}(<b>r</b>) {$translate->_('display.ui.reply')|lower} {/if}  
		(<b>p</b>) {$translate->_('common.print')|lower} 
		(<b>1-9</b>) change tab 
	</small>
	{/if}
					
</fieldset>

<div>
{include file="devblocks:cerberusweb.core::internal/notifications/context_profile.tpl" context=$page_context context_id=$page_context_id}
</div>

<div>
{include file="devblocks:cerberusweb.core::internal/macros/behavior/scheduled_behavior_profile.tpl" context=$page_context context_id=$page_context_id}
</div>

<div id="displayTabs">
	<ul>
		{$tabs = [conversation,activity,links,history]}

		<li><a href="{devblocks_url}ajax.php?c=display&a=showConversation&point={$point}&ticket_id={$ticket->id}{if $expand_all}&expand_all=1{/if}{/devblocks_url}">{$translate->_('display.tab.timeline')|capitalize}</a></li>
		<li><a href="{devblocks_url}ajax.php?c=internal&a=showTabActivityLog&scope=target&point={$point}&context={$page_context}&context_id={$page_context_id}{/devblocks_url}">{'common.activity_log'|devblocks_translate|capitalize}</a></li>		
		<li><a href="{devblocks_url}ajax.php?c=internal&a=showTabContextLinks&point={$point}&context=cerberusweb.contexts.ticket&id={$ticket->id}{/devblocks_url}">{$translate->_('common.links')} <div class="tab-badge">{DAO_ContextLink::count($page_context, $page_context_id)|default:0}</div></a></li>
		<li><a href="{devblocks_url}ajax.php?c=display&a=showContactHistory&point={$point}&ticket_id={$ticket->id}{/devblocks_url}">{'display.tab.history'|devblocks_translate} <div class="tab-badge">{DAO_Ticket::getViewCountForRequesterHistory('contact_history', $ticket, $visit->get('display.history.scope', ''))|default:0}</div></a></li>

		{foreach from=$tab_manifests item=tab_manifest}
			{$tabs[] = $tab_manifest->params.uri}
			<li><a href="{devblocks_url}ajax.php?c=profiles&a=showTab&ext_id={$tab_manifest->id}&point={$point}&context={$page_context}&context_id={$page_context_id}{/devblocks_url}"><i>{$tab_manifest->params.title|devblocks_translate}</i></a></li>
		{/foreach}
	</ul>
</div> 
<br>

{$selected_tab_idx=0}
{foreach from=$tabs item=tab_label name=tabs}
	{if $tab_label==$selected_tab}{$selected_tab_idx = $smarty.foreach.tabs.index}{/if}
{/foreach}

<script type="text/javascript">
	$(function() {
		var tabs = $("#displayTabs").tabs( { selected:{$selected_tab_idx} } );
		
		$('#btnDisplayTicketEdit').bind('click', function() {
			$popup = genericAjaxPopup('peek','c=internal&a=showPeekPopup&context={$page_context}&context_id={$page_context_id}&edit=1',null,false,'650');
			$popup.one('ticket_save', function(event) {
				event.stopPropagation();
				document.location.href = '{devblocks_url}c=profiles&type=ticket&id={$ticket->mask}{/devblocks_url}';
			});
		})
	});

	{include file="devblocks:cerberusweb.core::internal/macros/display/menu_script.tpl"}
</script>

{$profile_scripts = Extension_ContextProfileScript::getExtensions(true, $page_context)}
{if !empty($profile_scripts)}
{foreach from=$profile_scripts item=renderer}
	{if method_exists($renderer,'renderScript')}
		{$renderer->renderScript($page_context, $page_context_id)}
	{/if}
{/foreach}
{/if}

<script type="text/javascript">
{if $pref_keyboard_shortcuts}
$(document).keypress(function(event) {
	if(event.altKey || event.ctrlKey || event.metaKey)
		return;
	
	if($(event.target).is(':input'))
		return;

	// We only want shift on the Shift+R shortcut right now
	if(event.shiftKey && event.which != 82)
		return;
	
	hotkey_activated = true;
	
	switch(event.which) {
		case 49:  // (1) tab cycle
		case 50:  // (2) tab cycle
		case 51:  // (3) tab cycle
		case 52:  // (4) tab cycle
		case 53:  // (5) tab cycle
		case 54:  // (6) tab cycle
		case 55:  // (7) tab cycle
		case 56:  // (8) tab cycle
		case 57:  // (9) tab cycle
		case 58:  // (0) tab cycle
			try {
				idx = event.which-49;
				$tabs = $("#displayTabs").tabs();
				$tabs.tabs('select', idx);
			} catch(ex) { } 
			break;
		case 97:  // (A) read all
			try {
				$('#btnReadAll').click();
			} catch(ex) { } 
			break;
		case 99:  // (C) close
			try {
				$('#btnClose').click();
			} catch(ex) { } 
			break;
		case 101:  // (E) edit
			try {
				$('#btnDisplayTicketEdit').click();
			} catch(ex) { } 
			break;
		case 105:  // (I) recipients
			try {
				$('#aRecipients').click();
			} catch(ex) { } 
			break;
		case 109:  // (M) macros
			try {
				$('#btnDisplayMacros').click();
			} catch(ex) { } 
			break;
		case 111:  // (O) comment
			try {
				$('#btnComment').click();
			} catch(ex) { } 
			break;
		case 112:  // (P) print
			try {
				$('#btnPrint').click();
			} catch(ex) { } 
			break;
		case 82:   // (r)
		case 114:  // (R) reply to first message
			try {
				{if $expand_all}$btn = $('BUTTON.reply').last();{else}$btn = $('BUTTON.reply').first();{/if}
				if(event.shiftKey) {
					$btn.next('BUTTON.split-right').click();
				} else {
					$btn.click();
				}
			} catch(ex) { } 
			break;
		case 115:  // (S) spam
			try {
				$('#btnSpam').click();
			} catch(ex) { } 
			break;
		{if empty($ticket->owner_id)}
		case 116:  // (T) take
			try {
				genericAjaxGet('','c=display&a=doTake&ticket_id={$ticket->id}',function(e) {
					document.location.href = '{devblocks_url}c=profiles&type=ticket&id={$ticket->mask}{/devblocks_url}';
				});
			} catch(ex) { } 
			break;
		{else}
		case 117:  // (U) unassign
			try {
				genericAjaxGet('','c=display&a=doSurrender&ticket_id={$ticket->id}',function(e) {
					document.location.href = '{devblocks_url}c=profiles&type=ticket&id={$ticket->mask}{/devblocks_url}';
				});
			} catch(ex) { } 
			break;
		{/if}
		case 119:  // (W) watch
			try {
				$('#spanWatcherToolbar button:first').click();
			} catch(ex) { } 
			break;
		case 120:  // (X) delete
			try {
				$('#btnDelete').click();
			} catch(ex) { } 
			break;
		default:
			// We didn't find any obvious keys, try other codes
			hotkey_activated = false;
			break;
	}

	if(hotkey_activated)
		event.preventDefault();
});
{/if}
</script>
