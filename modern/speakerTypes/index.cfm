<cfscript>
	// get the speakerType bean
	rc.speakerTypeObj = new models.beans.SpeakerTypeBean();

	// ensure the isActive variable is set in rc
	if( !structKeyExists( rc, 'isActive') ) {
		rc.isActive = true;
	}

	// ensure the msg variable is set in rc
	if( !structKeyExists( rc, 'msg' ) ) {
		rc.msg = '';
	}
</cfscript>

<cfmodule template="/layouts/main.cfm">
	<cfoutput>
		<div id="page-heading">
			<h2 class="main-header">
				Speaker Types
			</h2>
			<div class="row">
				<nav aria-label="breadcrumb">
					<ol class="breadcrumb">
						<li class="breadcrumb-item" aria-current="page"><a href="/modern/index.cfm">Back to Modern Dashboard</a></li>
						<li class="breadcrumb-item" aria-current="page"><a href="edit.cfm?#rc.speakerTypeObj.getUidHash( 'url' )#=#rc.speakerTypeObj.getEncUid( 'url' )#">Create New Speaker Type</a></li>
					</ol>
				</nav>
			</div>
		</div>

		<div class="table-vertical">
			<table id="speakerType-table" class="table table-striped table-bordered">
				<thead>
					<tr class="table-theme">
						<th>
							Speaker Type ID
						</th>
						<th>
							Speaker Type Name
						</th>
						<th>
							Sort Order
						</th>
						<th data-orderable="false" style="width:10%;">Actions</th>
					</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
		</div>

		<div class="modal fade" id="speakerTypeModal" tabindex="-1" role="dialog" aria-labelledby="speakerTypeModalLabel" aria-hidden="true">
			<div class="modal-dialog">
				<div class="modal-content">
					<div class="modal-header alert-danger">
						<h5 class="modal-title" id="speakerTypeModalLabel">Confirm Delete SpeakerType</h5>
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

	</cfoutput>
</cfmodule>



<!---- Datatable --->
<script src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.10.20/js/dataTables.bootstrap4.min.js"></script>
<script>
$(document).ready(function() {
	$('#speakerType-table').DataTable( {
		'stateSave': true,
		'processing': true,
		'serverSide': true,
		'responsive': true,
		'ajax': {
			'url': '<cfoutput>/modern/speakerTypes/_handler.cfm?method=datatable&isActive=#rc.isActive#</cfoutput>',
			'type': 'POST'
		},
		"columns": [
			{ "data": "speakerTypeID" },
			{ "data": "speakerTypeName" },
			{ "data": "sortOrder" },
			{ "data": "actions" }
		]
	} );

	$('#speakerTypeModal').on('show.bs.modal', function (e) {
		var id = $(e.relatedTarget).data('id');
		var entity = $(e.relatedTarget).data('entity');
		$('#speakerTypeModal').data('id', id);
		$('#entityName').text(entity);
	});

	$('#btnConfirm').click(function () {
		var id = $('#speakerTypeModal').data('id');
		$('#speakerTypeModal').modal('hide');
		window.location.href = '<cfoutput>_handler.cfm?method=deactivate&#rc.speakerTypeObj.getUidHash( 'url' )#=</cfoutput>' + id;
	});

	$("body").tooltip({
		selector: '[data-toggle="tooltip"]'
	});

});
</script>