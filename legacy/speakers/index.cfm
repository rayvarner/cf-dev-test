<cfscript>
	// TODO - load up speaker recs to be displayed order by lastName, firstName
	recs = entityLoad( "Speaker", {}, "lastName asc, firstName asc" );
</cfscript>

<cfmodule template="/layouts/main.cfm">
	<cfoutput>
		<h1>Speakers</h1>
		<div class="row">
			<nav aria-label="breadcrumb">
				<ol class="breadcrumb">
					<li class="breadcrumb-item" aria-current="page"><a href="../speakerTypes/index.cfm">Back to Speaker Types</a></li>
					<li class="breadcrumb-item" aria-current="page"><a href="edit.cfm?id=0">Create New Speaker</a></li>
				</ol>
			</nav>
		</div>

		<div class="table-vertical">
			<!--- output the list of speakers on this page. fields to output in datatable speakerID, firstName, lastName, email, company and button to edit --->
			<!--- TODO - check to see if there are any speakers in the database --->
			<cfif arrayLen( recs) >
				<table cellpadding="0" cellspacing="0" border="0" class="table table-striped table-bordered datatables">
					<thead>
						<tr>
							<th>ID</th>
							<th>First Name</th>
							<th>Last Name</th>
							<th>Email</th>
							<th>Company</th>
							<th width="30%"></th>
						</tr>
					</thead>

					<tbody>
						<!--- TODO - loop through speaker recs and complete the table --->
						<cfloop array="#recs#" index="i">
							<tr>
								<td data-title="ID">#i.getSpeakerID()#</td>
								<td data-title="First Name">#i.getFirstName()#</td>
								<td data-title="Last Name">#i.getLastName()#</td>
								<td data-title="Email">#i.getEmail()#</td>
								<td data-title="Company">#i.getCompany()#</td>
								<td data-title="Actions">
									<div class="row options">
										<div class="col-lg-4 col-md-6">
											<a href="./edit.cfm?id=#i.getSpeakerID()#" class="btn btn-sm btn-primary">edit</a>
										</div>
									</div>
								</td>
							</tr>
						</cfloop>
						
						
					</tbody>
				</table>
			<cfelse>
				<p>No speakers have been setup</p>
			</cfif>
		</div>
	</cfoutput>
</cfmodule>