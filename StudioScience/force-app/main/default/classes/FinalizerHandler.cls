/*
   Copyright 2023 Google LLC

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
 * @description The `FinalizerHandler` class is a utility class that handles the execution of dynamic finalizers.
 *
 * Finalizers are classes that implement the `TriggerAction.DmlFinalizer` interface and are defined in Custom Metadata.
 * Finalizers can be used to perform custom actions after all DML operations have completed.
 *
 * The `FinalizerHandler` class provides the following functionality:
 *
 * - A way to bypass the execution of specific finalizers.
 * - A way to check if a specific finalizer is bypassed.
 * - A way to clear all bypasses.
 * - A way to handle dynamic finalizers.
 * ---
 * To use the `FinalizerHandler` class, you must first create a Custom Metadata type called `DML_Finalizer__mdt`.
 * The `DML_Finalizer__mdt` Custom Metadata type must have the following fields:
 *
 * - `Apex_Class_Name__c`: The name of the Apex class that implements the finalizer.
 * - `Order__c`: The order in which the finalizer should be executed.
 * - `Bypass_Execution__c`: A flag that indicates whether or not the finalizer should be bypassed.
 * - `Bypass_Permission__c`: The permission required to bypass the finalizer.
 * - `Required_Permission__c`: The permission required to execute the finalizer.
 * ---
 * Once you have created the `DML_Finalizer__mdt` Custom Metadata type, you can create finalizers by creating records
 * in the `DML_Finalizer__mdt` object.
 *
 * To bypass the execution of a specific finalizer, you can call the `bypass` method of the `FinalizerHandler` class.
 * To check if a specific finalizer is bypassed, you can call the `isBypassed` method of the `FinalizerHandler` class.
 * To clear all bypasses, you can call the `clearAllBypasses` method of the `FinalizerHandler` class.
 *
 * To handle dynamic finalizers, you can call the `handleDynamicFinalizers` method of the `FinalizerHandler` class.
 * The `handleDynamicFinalizers` method will instantiate and execute all finalizers that are not bypassed.
 */
public with sharing virtual class FinalizerHandler {
	@TestVisible
	private static final String DML_IN_FINALIZER_ERROR = 'DML is not allowed within the finalizer context.';
	@TestVisible
	private static final String INVALID_TYPE_ERROR_FINALIZER = 'Please check the DML Finalizer Custom Metadata. The {0} class does not implement the TriggerAction.DmlFinalizer interface.';
	@TestVisible
	private static final String INVALID_CLASS_ERROR_FINALIZER = 'Please check the DML Finalizer Custom Metadata. The {0} class does not exist.';

	@TestVisible
	private static Set<String> bypassedFinalizers = new Set<String>();

	@TestVisible
	private static Map<String, Boolean> permissionMap = new Map<String, Boolean>();

	/**
	 * @description Bypass the execution of a specific finalizer.
	 * @param finalizer The name of the finalizer to bypass.
	 */
	public static void bypass(String finalizer) {
		FinalizerHandler.bypassedFinalizers.add(finalizer);
	}

	/**
	 * @description Clear the bypass for a specific finalizer.
	 * @param finalizer The name of the finalizer to clear the bypass for.
	 */
	public static void clearBypass(String finalizer) {
		FinalizerHandler.bypassedFinalizers.remove(finalizer);
	}

	/**
	 * @description Check if a specific finalizer is bypassed.
	 * @param finalizer The name of the finalizer to check.
	 * @return True if the finalizer is bypassed, false otherwise.
	 */
	public static Boolean isBypassed(String finalizer) {
		return FinalizerHandler.bypassedFinalizers.contains(finalizer);
	}

	/**
	 * @description Clear all bypasses.
	 */
	public static void clearAllBypasses() {
		FinalizerHandler.bypassedFinalizers.clear();
	}

	/**
	 * @description Handle dynamic finalizers.nstantiates and executes finalizers based on metadata.
	 */
	public virtual void handleDynamicFinalizers() {
		Context context = new Context();
		List<DML_Finalizer__mdt> sortedFinalizers = getSortedFinalizers();
		for (DML_Finalizer__mdt finalizerMetadata : sortedFinalizers) {
			if (finalizerMetadata.Bypass_Execution__c) {
				return;
			}
			populatePermissionMap(finalizerMetadata.Bypass_Permission__c);
			populatePermissionMap(finalizerMetadata.Required_Permission__c);
			if (
				isNotBypassed(
					finalizerMetadata.Bypass_Permission__c,
					finalizerMetadata.Required_Permission__c
				)
			) {
				callReferencedFinalizer(finalizerMetadata, context);
			}
		}
	}

	/**
	 * @description Dynamically instantiates and executes a finalizer based on metadata.
	 * @param finalizerMetadata The metadata of the finalizer to execute.
	 * @param context The context to pass to the finalizer's `execute` method.
	 */
	private void callReferencedFinalizer(
		DML_Finalizer__mdt finalizerMetadata,
		Context context
	) {
		Object dynamicInstance;
		String className = finalizerMetadata.Apex_Class_Name__c;
		if (FinalizerHandler.isBypassed(className)) {
			return;
		}
		try {
			dynamicInstance = Type.forName(className).newInstance();
		} catch (System.NullPointerException e) {
			handleFinalizerException(INVALID_CLASS_ERROR_FINALIZER, className);
		}
		TriggerAction.DmlFinalizer finalizer;
		try {
			finalizer = (TriggerAction.DmlFinalizer) dynamicInstance;
		} catch (System.TypeException e) {
			handleFinalizerException(INVALID_TYPE_ERROR_FINALIZER, className);
		}
		Integer dmlOperationsBefore = Limits.getDmlStatements();
		finalizer.execute(context);
		if (limits.getDmlStatements() > dmlOperationsBefore) {
			throw new FinalizerException(DML_IN_FINALIZER_ERROR);
		}
	}

	/**
	 * @description Get the sorted finalizers.
	 * @return A list of sorted finalizers.
	 */
	private List<DML_Finalizer__mdt> getSortedFinalizers() {
		List<FinalizerSorter> sorters = new List<FinalizerSorter>();
		for (DML_Finalizer__mdt finalizer : this.allFinalizers) {
			sorters.add(new FinalizerSorter(finalizer));
		}
		List<DML_Finalizer__mdt> results = new List<DML_Finalizer__mdt>();
		sorters.sort();
		for (FinalizerSorter sorter : sorters) {
			results.add(sorter.metadata);
		}
		return results;
	}

	private void handleFinalizerException(String errorFormat, String className) {
		throw new FinalizerException(
			String.format(errorFormat, new List<String>{ className })
		);
	}

	/**
	 * @description Check if the finalizer is not bypassed.
	 * @param requiredPermission The required permission.
	 * @param bypassPermission The bypass permission.
	 * @return True if the finalizer is not bypassed, false otherwise.
	 */
	private boolean isNotBypassed(
		String requiredPermission,
		String bypassPermission
	) {
		return !((requiredPermission != null &&
		permissionMap.get(requiredPermission)) ||
		(bypassPermission != null && !permissionMap.get(bypassPermission)));
	}

	/**
	 * @description Populate the permission map.
	 * @param permissionName The permission name.
	 */
	private void populatePermissionMap(String permissionName) {
		if (permissionName != null && !permissionMap.containsKey(permissionName)) {
			permissionMap.put(
				permissionName,
				FeatureManagement.checkPermission(permissionName)
			);
		}
	}

	@TestVisible
	private List<DML_Finalizer__mdt> allFinalizers {
		get {
			if (allFinalizers == null) {
				allFinalizers = DML_Finalizer__mdt.getAll().values();
			}
			return allFinalizers;
		}
		private set;
	}

	private class FinalizerSorter implements Comparable {
		public final DML_Finalizer__mdt metadata;

		/**
		 * @description Constructor that takes a `DML_Finalizer__mdt` object and sets the `metadata` property to
		 * the value of the `DML_Finalizer__mdt` object.
		 *
		 * @param metadata The `DML_Finalizer__mdt` object to set the `metadata` property to.
		 */
		public FinalizerSorter(DML_Finalizer__mdt metadata) {
			this.metadata = metadata;
		}

		/**
		 * @description Compares this `FinalizerSorter` object to another object.
		 *
		 * @param other The object to compare this `FinalizerSorter` object to.
		 * @return A negative integer, zero, or a positive integer as this `FinalizerSorter` object is less than,
		 *  equal to, or greater than the specified object.
		 */
		public Integer compareTo(Object other) {
			Decimal difference = (this.metadata.Order__c -
			((FinalizerSorter) other).metadata.Order__c);
			return difference < 0 ? -1 : difference == 0 ? 0 : 1;
		}
	}

	/**
	 * @description Context to be passed to the implementation's `.execute` methodis object's definition is empty. We are establishing the interface
	 * to include the context to help future-proof the interface's specifications.
	 */
	public class Context {
	}

	/**
	 * @description Finalizer exception.
	 */
	private class FinalizerException extends Exception {
	}
}