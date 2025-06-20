/*
   Copyright 2021 Google LLC

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

	https://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

/**
 * @group Trigger Actions Framework
 * @description This class implements the TriggerAction interface and provides a framework for
 * executing Flows before or after the insert, update, delete, or undelete of records.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public virtual inherited sharing class TriggerActionFlow implements TriggerAction.BeforeInsert, TriggerAction.AfterInsert, TriggerAction.BeforeUpdate, TriggerAction.AfterUpdate, TriggerAction.BeforeDelete, TriggerAction.AfterDelete, TriggerAction.AfterUndelete {
	@TestVisible
	private static final String RECORD_VARIABLE_NOT_FOUND_ERROR = 'There must be a variable defined in this flow with api name of "record" and type of "record" that is marked as "available for output"';
	@TestVisible
	private static Set<String> bypassedFlows = new Set<String>();
	@TestVisible
	private static InvocableAction invocableAction = new InvocableAction();

	public String flowName;
	public Boolean allowRecursion;

	/**
	 * @description This method bypasses the execution of the Flow for the specified list of records.
	 *
	 * @param flowName The API name of the Flow to bypass.
	 */
	public static void bypass(String flowName) {
		TriggerActionFlow.bypassedFlows.add(flowName);
	}

	/**
	 * @description This method clears the bypass for the specified list of records.
	 *
	 * @param flowName The API name of the Flow to clear the bypass for.
	 */
	public static void clearBypass(String flowName) {
		TriggerActionFlow.bypassedFlows.remove(flowName);
	}

	/**
	 * @description This method checks if the Flow is bypassed for the specified list of records.
	 *
	 * @param flowName The API name of the Flow to check the bypass for.
	 * @return `true` if the Flow is bypassed for the specified list of records, `false` otherwise.
	 */
	public static Boolean isBypassed(String flowName) {
		return TriggerActionFlow.bypassedFlows.contains(flowName);
	}

	/**
	 * @description This method clears all bypasses for all Flows.
	 */
	public static void clearAllBypasses() {
		TriggerActionFlow.bypassedFlows.clear();
	}

	/**
	 * @description This method validates the specified bypass type.
	 *
	 * @param bypassType The bypass type to validate.
	 * @throws IllegalArgumentException if the bypass type is not valid.
	 */
	public static void validateType(String bypassType) {
		if (!TriggerActionConstants.REQUEST_TYPES.contains(bypassType)) {
			throw new IllegalArgumentException(TriggerActionConstants.INVALID_TYPE);
		}
	}

	/**
	 * @description This method executes the Flow for the specified list of records before the insert of the records.
	 *
	 * @param newList The list of records to execute the Flow for.
	 */
	public void beforeInsert(List<SObject> newList) {
		if (flowIsBypassed()) {
			return;
		}
		List<Invocable.Action.Result> results = invokeAction(
			getInterviewInputs(newList, TriggerActionConstants.RECORD_VARIABLE)
		);
		handleInvocableResults(results, newList);
		applyFieldValuesDuringBefore(results, newList);
	}

	/**
	 * @description This method executes the Flow for the specified list of records after the insert of the records.
	 *
	 * @param newList The list of records to execute the Flow for.
	 */
	public void afterInsert(List<SObject> newList) {
		if (flowIsBypassed()) {
			return;
		}
		handleInvocableResults(
			invokeAction(
				getInterviewInputs(newList, TriggerActionConstants.RECORD_VARIABLE)
			),
			newList
		);
	}

	/**
	 * @description This method executes the Flow for the specified list of records before the update of the records.
	 *
	 * @param newList The list of new records that are being updated.
	 * @param oldList The list of old records that are being updated.
	 */
	public void beforeUpdate(List<SObject> newList, List<SObject> oldList) {
		if (flowIsBypassed()) {
			return;
		}
		List<sObject> recordsNotYetProcessed = new List<sObject>();
		List<sObject> oldRecordsNotYetProcessed = new List<sObject>();
		for (Integer i = 0; i < newList.size(); i++) {
			sObject record = newList[i];
			if (
				TriggerBase.idToNumberOfTimesSeenBeforeUpdate.get(record.id) == 1 ||
				(allowRecursion == true)
			) {
				recordsNotYetProcessed.add(record);
				oldRecordsNotYetProcessed.add(oldList[i]);
			}
		}
		if (recordsNotYetProcessed.isEmpty()) {
			return;
		}
		List<Invocable.Action.Result> results = invokeAction(
			getInterviewInputs(recordsNotYetProcessed, oldRecordsNotYetProcessed)
		);
		handleInvocableResults(results, recordsNotYetProcessed);
		applyFieldValuesDuringBefore(results, recordsNotYetProcessed);
	}

	/**
	 * @description This method executes the Flow for the specified list of records after the update of the records.
	 *
	 * @param newList The list of new records that are being updated.
	 * @param oldList The list of old records that are being updated.
	 */
	public void afterUpdate(List<SObject> newList, List<SObject> oldList) {
		if (flowIsBypassed()) {
			return;
		}
		List<sObject> recordsNotYetProcessed = new List<sObject>();
		List<sObject> oldRecordsNotYetProcessed = new List<sObject>();
		for (Integer i = 0; i < newList.size(); i++) {
			sObject record = newList[i];
			if (
				TriggerBase.idToNumberOfTimesSeenAfterUpdate.get(record.id) == 1 ||
				(allowRecursion == true)
			) {
				recordsNotYetProcessed.add(record);
				oldRecordsNotYetProcessed.add(oldList[i]);
			}
		}
		if (recordsNotYetProcessed.isEmpty()) {
			return;
		}
		handleInvocableResults(
			invokeAction(
				getInterviewInputs(recordsNotYetProcessed, oldRecordsNotYetProcessed)
			),
			recordsNotYetProcessed
		);
	}

	/**
	 * @description This method executes the Flow for the specified list of records before the delete of the records.
	 *
	 * @param oldList The list of old records that are being deleted.
	 */
	public void beforeDelete(List<SObject> oldList) {
		if (flowIsBypassed()) {
			return;
		}
		handleInvocableResults(
			invokeAction(
				getInterviewInputs(
					oldList,
					TriggerActionConstants.RECORD_PRIOR_VARIABLE
				)
			),
			oldList
		);
	}

	/**
	 * @description This method executes the Flow for the specified list of records after the delete of the records.
	 *
	 * @param oldList The list of old records that are being deleted.
	 */
	public void afterDelete(List<SObject> oldList) {
		if (flowIsBypassed()) {
			return;
		}
		handleInvocableResults(
			invokeAction(
				getInterviewInputs(
					oldList,
					TriggerActionConstants.RECORD_PRIOR_VARIABLE
				)
			),
			oldList
		);
	}

	/**
	 * @description This method executes the Flow for the specified list of records before the undelete of the records.
	 *
	 * @param newList The list of records that are being restored.
	 */
	public void afterUndelete(List<SObject> newList) {
		if (flowIsBypassed()) {
			return;
		}
		handleInvocableResults(
			invokeAction(
				getInterviewInputs(newList, TriggerActionConstants.RECORD_VARIABLE)
			),
			newList
		);
	}

	private Boolean flowIsBypassed() {
		if (String.isBlank(flowName)) {
			throw new IllegalArgumentException(
				TriggerActionConstants.INVALID_FLOW_NAME
			);
		}
		return TriggerActionFlow.isBypassed(flowName);
	}

	private List<Invocable.Action.Result> invokeAction(
		List<Map<String, Object>> inputs
	) {
		return invocableAction.invokeAction(this.flowName, inputs);
	}

	private void applyFlowValues(
		sObject stateBeforeFlow,
		sObject stateAfterFlow
	) {
		Boolean hasBeenMutated = false;
		Map<String, Object> afterFlowMap = stateAfterFlow.getPopulatedFieldsAsMap();
		for (String fieldName : afterFlowMap.keySet()) {
			if (stateBeforeFlow.get(fieldName) != stateAfterFlow.get(fieldName)) {
				stateBeforeFlow.put(fieldName, stateAfterFlow.get(fieldName));
				hasBeenMutated = true;
			}
		}
		/**
		 * @description If the record is not mutated, then any errors will persist after the flow is complete,
		 * so there is no need to re-add them
		 */
		if (hasBeenMutated == false) {
			return;
		}
		for (Database.Error err : stateAfterFlow.getErrors()) {
			/**
			 * @description Unfortunately, err.getFields() does not include the field api name after
			 * calling .addError(String fieldApiName, String message) from within a flow,
			 * so when the record is mutated before save,
			 * the exact field location for the error cannot be applied.
			 */
			stateBeforeFlow.addError(err.getMessage());
		}
	}

	/**
	 * @description This method gets the interview inputs for the specified list of new and old records.
	 *
	 * @param newList The list of new records.
	 * @param oldList The list of old records.
	 * @return A list of interview inputs.
	 */
	private List<Map<String, Object>> getInterviewInputs(
		List<SObject> newList,
		List<SObject> oldList
	) {
		List<Map<String, Object>> result = new List<Map<String, Object>>();
		for (Integer i = 0; i < newList.size(); i++) {
			SObject oldRecord = oldList[i];
			SObject newRecord = newList[i];
			result.add(
				new Map<String, Object>{
					TriggerActionConstants.RECORD_PRIOR_VARIABLE => oldRecord,
					TriggerActionConstants.RECORD_VARIABLE => newRecord
				}
			);
		}
		return result;
	}

	protected virtual List<Map<String, Object>> getInterviewInputs(
		List<SObject> records,
		String variableName
	) {
		List<Map<String, Object>> result = new List<Map<String, Object>>();
		for (Integer i = 0; i < records.size(); i++) {
			result.add(new Map<String, Object>{ variableName => records[i] });
		}
		return result;
	}

	private void applyFieldValuesDuringBefore(
		List<Invocable.Action.Result> results,
		List<SObject> newList
	) {
		for (Integer i = 0; i < results.size(); i++) {
			Invocable.Action.Result result = results[i];
			if (result.isSuccess() == true) {
				SObject newRecordWhenFlowIsComplete = (SObject) (result.getOutputParameters()
					.get(TriggerActionConstants.RECORD_VARIABLE));
				if (newRecordWhenFlowIsComplete == null) {
					throw new IllegalArgumentException(
						this.flowName + ': ' + RECORD_VARIABLE_NOT_FOUND_ERROR
					);
				}
				applyFlowValues(newList[i], newRecordWhenFlowIsComplete);
			}
		}
	}

	private void handleInvocableResults(
		List<Invocable.Action.Result> results,
		List<SObject> records
	) {
		for (Integer i = 0; i < results.size(); i++) {
			Invocable.Action.Result result = results[i];
			if (result.isSuccess() == false) {
				records[i].addError(getFormattedErrorMessage(result.getErrors()));
			}
		}
	}

	private String getFormattedErrorMessage(List<Invocable.Action.Error> errors) {
		List<String> messagesAndCodes = new List<String>();
		for (Invocable.Action.Error error : errors) {
			messagesAndCodes.add(error.getCode() + ' - ' + error.getMessage());
		}
		return this.flowName + ': ' + String.join(messagesAndCodes, ', ');
	}

	@TestVisible
	private virtual class InvocableAction {
		/**
		 * @description This method invokes the specified Flow with the specified inputs.
		 *
		 * @param flowApiName The API name of the Flow to invoke.
		 * @param inputs The list of inputs to pass to the Flow.
		 * @return The list of results from the Flow invocation.
		 */
		public virtual List<Invocable.Action.Result> invokeAction(
			String flowApiName,
			List<Map<String, Object>> inputs
		) {
			Invocable.Action action = Invocable.Action.createCustomAction(
				TriggerActionConstants.FLOW_STRING,
				flowApiName
			);
			action.setInvocations(inputs);
			return action.invoke();
		}
	}
}