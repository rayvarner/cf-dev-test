<cfscript>
	// simulate request context
	if( !structKeyExists( variables, "rc" ) ){
		rc = {};
	}

	structAppend( rc, form );
	structAppend( rc, url );

	// TODO - get the speaker bean
	rc.speakerObj = new models.beans.SpeakerBean();
	// TODO - set speakerID of the speaker bean from obfuscated and encrypted value passed in url
	rc.speakerObj.setSpeakerID( rc.speakerObj.getDecUid( rc[ rc.speakerObj.getUidHash( 'url' ) ], 'url' ) );
	// get a random token key for CSRF protection
	rc.tokenKey = application.securityService.generateTokenKey();

	// TODO - check if speakerID is a non-zero guid
	if( rc.speakerObj.getSpeakerID() neq application.zeroGuid ) {
		// TODO - it is, populate the speaker bean from the database
		rc.speakerObj = application.speakerService.getSpeakerByID( rc.speakerObj.getSpeakerID() );
	}

	// TODO - get the speaker types to populate the select box, use the filter function in speakerTypeService
 	qGetSpeakerTypes = application.speakerTypeService.filter(
		isActive = true,
		orderBy = 'speakerTypeName',
		returnColumns = 'speakerTypeID, speakerTypeName',
		pagination = false,
		cache = false, // TBD: Set this to true in production
		clearCache = structKeyExists( rc, 'clearCache' ) ? rc.clearCache : false
	);

	// set a default value for a new speaker
	existingSpeakerTypeID = '';
	// if editing, store the speakerTypeID for clarity when populating the form
	if( isNumeric(rc.speakerObj.getSpeakerTypeID()) && rc.speakerObj.getSpeakerTypeID() > 0 ) {
		existingSpeakerTypeID = rc.speakerObj.getSpeakerTypeID();
	}

</cfscript>

<cfoutput>
	<cfmodule template="/layouts/main.cfm">
	<div class="dashboard-content content">
		<h3 class="skinny-page-name">
			<div class="container-fluid">
				<strong>Speaker Details</strong>
			</div>
		</h3>
		<div class="container-fluid">

			<div class="text-right mb-3">
				<a href="/modern/" class="btn btn-secondary">Back To Dashboard</a>
			</div>


		<!-- form -->
		<form role="form" name="recEditFrm" id="recEditFrm" action="/modern/speakers/_handler.cfm?method=update" method="post" class="form-horizontal" data-toggle="validator">
			<!--- TODO - uncomment once you have the speaker bean in rc.speakerObj--->
			<input type="hidden" name="#rc.speakerObj.getUidHash( 'form' )#" value="#rc.speakerObj.getEncUid( 'form' )#">
			<input type="hidden" name="#rc.speakerObj.getTokenKeyHash()#" value="#rc.tokenKey#">
			<input type="hidden" name="#rc.speakerObj.getTokenHash()#" value="#CSRFGenerateToken( rc.tokenKey, true )#">
			

			<div class="form-group row">
				<label for="speakerTypeID" class="col-sm-2 col-form-label col-form-label-sm">
					Speaker Type
				</label>
				<div class="col-sm-10">
					<select name="speakerTypeID" class="form-control form-control-sm" id="speakerTypeID" data-error="Please choose a speakerType.">
						<option value="">Select speakerType</option>
						<!-- TODO build option list using values from a speaker type query -->
						<cfif qGetSpeakerTypes.recordcount>
							<cfoutput query="qGetSpeakerTypes">
								<option value="#qGetSpeakerTypes.speakerTypeID#"
									<cfif qGetSpeakerTypes.speakerTypeID eq existingSpeakerTypeID>selected</cfif>
								>#qGetSpeakerTypes.speakerTypeName#</option>
							</cfoutput>
						</cfif>
					</select>
				</div>
			</div>
			<div class="form-group row">
				<label for="firstName" class="col-sm-2 col-form-label col-form-label-sm">
					First Name
				</label>
				<div class="col-sm-10">
					<input type="text" name="firstName" class="form-control form-control-sm" id="firstName" value="#encodeForHTMLAttribute( rc.speakerObj.getFirstName() )#" placeholder="First Name">
				</div>
			</div>
			<div class="form-group row">
				<label for="lastName" class="col-sm-2 col-form-label col-form-label-sm">
					Last Name
				</label>
				<div class="col-sm-10">
					<input type="text" name="lastName" class="form-control form-control-sm" id="lastName" value="#encodeForHTMLAttribute( rc.speakerObj.getLastName() )#" placeholder="Last Name">
				</div>
			</div>
			<div class="form-group row">
				<label for="jobTitle" class="col-sm-2 col-form-label col-form-label-sm">
					Job Title
				</label>
				<div class="col-sm-10">
					<input type="text" name="jobTitle" class="form-control form-control-sm" id="jobTitle" value="#encodeForHTMLAttribute( rc.speakerObj.getJobTitle() )#" placeholder="Job title">
				</div>
			</div>
			<div class="form-group row">
				<label for="company" class="col-sm-2 col-form-label col-form-label-sm">
					Company
				</label>
				<div class="col-sm-10">
					<input type="text" name="company" class="form-control form-control-sm" id="company" value="#encodeForHTMLAttribute( rc.speakerObj.getCompany() )#" placeholder="Company">
				</div>
			</div>
			<div class="form-group row">
				<label for="email" class="col-sm-2 col-form-label col-form-label-sm">
					Email
				</label>
				<div class="col-sm-10">
					<input type="text" name="email" class="form-control form-control-sm" id="email" value="#encodeForHTMLAttribute( rc.speakerObj.getEmail() )#" placeholder="Email" data-error="Email is required">
				</div>
			</div>
			<div class="form-group row">
				<label for="bio" class="col-sm-2 col-form-label col-form-label-sm">
					Bio
				</label>
				<div class="col-sm-10">
					<textarea name="bio">#encodeForHTML( rc.speakerObj.getBio() )#</textarea>
				</div>
			</div>
			<div class="form-group row">
				<label for="hideSpeaker" class="col-sm-2 col-form-label col-form-label-sm required">
					Hide Speaker
				</label>
				<div class="col-sm-10">
					<select name="hideSpeaker" class="form-control form-control-sm" id="hideSpeaker" data-error="Please choose a hideSpeaker." required>
						<option value="false" <cfif not rc.speakerObj.getHideSpeaker()>selected</cfif> >No</option>
						<option value="true" <cfif rc.speakerObj.getHideSpeaker()>selected</cfif>>Yes</option>
					</select>
				</div>
			</div>
			<div class="form-group">
				<div class="card-footer text-right clearfix">
					<input type="submit" name="btnSubmit" value="Save Speaker" class="btn btn-success btn-lg">
				</div>
			</div>
		</form>

		<!-- /.form -->
		</div>
	</div>
	</cfmodule>
</cfoutput>

<cfsavecontent variable="rc.js">
	<script src="https://cdnjs.cloudflare.com/ajax/libs/1000hz-bootstrap-validator/0.11.5/validator.min.js"></script>
</cfsavecontent>
