<cfscript>

	// simulate request context
	if( !structKeyExists( variables, "rc" ) ){
		rc = {};
	}

	structAppend( rc, form );
	structAppend( rc, url );

	// TODO - get the speaker bean
	rc.speakerObj = new models.beans.SpeakerBean();

	// ensure the isActive variable is set in rc
	if( !structKeyExists( rc, 'isActive') ) {
		rc.isActive = true;
	}

	// ensure the msg variable is set in rc
	if( !structKeyExists( rc, 'msg' ) ) {
		rc.msg = '';
	}
</cfscript>

<cfoutput>
	<cfmodule template="/layouts/main.cfm">

		<div id="page-heading">
			<h2 class="main-header">
				Speakers
			</h2>
			<div class="row">
				<nav aria-label="breadcrumb">
					<ol class="breadcrumb">
						<li class="breadcrumb-item" aria-current="page"><a href="/modern/index.cfm">Back to Modern Dashboard</a></li>
						<!--- TODO - build link to the edit screen using the getUidHash() function in speakerObj for the parameter name and set the value to the encrypted uid of the speakerObj --->
						<li class="breadcrumb-item" aria-current="page"><a href="/modern/speakers/edit.cfm?#rc.speakerObj.getUidHash( 'url' )#=#rc.speakerObj.getEncUid( 'url' )#">Create New Speaker</a></li>
					</ol>
				</nav>
			</div>
		</div>

		<div class="table-vertical">
			<table id="speaker-table" class="table table-striped table-bordered">
				<thead>
					<tr class="table-theme">
						<th>
							Speaker ID
						</th>
						<th>
							First Name
						</th>
						<th>
							Last Name
						</th>
						<th>
							Company
						</th>
						<th>
							Email
						</th>
						<th data-orderable="false" style="width:10%;">Actions</th>
					</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
		</div>

		<div class="modal fade" id="speakerModal" tabindex="-1" role="dialog" aria-labelledby="speakerModalLabel" aria-hidden="true">
			<div class="modal-dialog">
				<div class="modal-content">
					<div class="modal-header alert-danger">
						<h5 class="modal-title" id="speakerModalLabel">Confirm Delete Speaker</h5>
						<button type="button" class="close" data-dismiss="modal" aria-label="Close">
							<span aria-hidden="true">&times;</span>
						</button>
					</div>
					<div class="modal-body">
						<h5>Are you sure you want to <strong><span class="text-danger">DELETE</span> <span id="entityName"></span></strong>?</h5>
					</div>
					<div class="modal-footer alert-danger">
						<button type="button" class="btn btn-danger" id="btnConfirm">Yes</button>
						<button type="button" class="btn btn-default" data-dismiss="modal">No</button>
					</div>
				</div>
			</div>
		</div>
	</cfmodule>
</cfoutput>

<!---- Datatable --->
<script src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.10.20/js/dataTables.bootstrap4.min.js"></script>
<script>
$(document).ready(function() {
	$('#speaker-table').DataTable( {
		'stateSave': true,
		'processing': true,
		'serverSide': true,
		'responsive': true,
		'ajax': {
			'url': '<cfoutput>/modern/speakers/_handler.cfm?method=datatable&isActive=#rc.isActive#</cfoutput>', //TODO - make call to datatable in _handler.cfm
			'type': 'POST'
		},
		"columns": [
			{ "data": "speakerID" },
			{ "data": "firstName" },
			{ "data": "lastName" },
			{ "data": "company" },
			{ "data": "email" },
			{ "data": "actions" }
		]
	} );

	$('#speakerModal').on('show.bs.modal', function (e) {
		var id = $(e.relatedTarget).data('id');
		var entity = $(e.relatedTarget).data('entity');
		$('#speakerModal').data('id', id);
		$('#entityName').text(entity);
	});

	$('#btnConfirm').click(function () {
		var id = $('#speakerModal').data('id');
		$('#speakerModal').modal('hide');
		// TODO - build a link to the deactivate method in _handler.cfm
		window.location.href = '<cfoutput>_handler.cfm?method=deactivate&#rc.speakerObj.getUidHash( 'url' )#=</cfoutput>' + id;
	});

	$("body").tooltip({
		selector: '[data-toggle="tooltip"]'
	});

});
</script>