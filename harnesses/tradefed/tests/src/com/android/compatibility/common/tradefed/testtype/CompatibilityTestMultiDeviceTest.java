/*
 * Copyright (C) 2017 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.android.compatibility.common.tradefed.testtype;

import com.android.tradefed.build.IBuildInfo;
import com.android.tradefed.device.DeviceNotAvailableException;
import com.android.tradefed.device.ITestDevice;
import com.android.tradefed.invoker.IInvocationContext;
import com.android.tradefed.testtype.VtsMultiDeviceTest;
import com.android.tradefed.testtype.IAbi;

import java.io.FileNotFoundException;
import java.util.LinkedList;
import java.util.Map;
import java.util.ArrayList;
import java.util.HashMap;
import org.easymock.EasyMock;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;
import static org.junit.Assert.assertEquals;

/**
 * Unit tests for {@link CompatibilityTestMultiDevice}.
 */
@RunWith(JUnit4.class)
public class CompatibilityTestMultiDeviceTest {
    CompatibilityTestMultiDevice mTest = null;
    private ITestDevice mMockDevice;
    private ModuleDefMultiDevice moduleDef;
    Map<ITestDevice, IBuildInfo> deviceInfos;
    IInvocationContext invocationContext;

    @Before
    public void setUp() throws Exception {
        mMockDevice = EasyMock.createMock(ITestDevice.class);
        IAbi abi = EasyMock.createMock(IAbi.class);
        EasyMock.expect(abi.getName()).andReturn("FAKE_ABI");
        moduleDef = new ModuleDefMultiDevice("FAKE_MODULE", abi, new VtsMultiDeviceTest(),
                new ArrayList<>(), new ArrayList<>(), null);
        deviceInfos = new HashMap<>();
        invocationContext = EasyMock.createMock(IInvocationContext.class);

        mTest = new CompatibilityTestMultiDevice(1, new ModuleRepoMultiDevice() {
            @Override
            public boolean isInitialized() {
                return true;
            }
            @Override
            public LinkedList<IModuleDef> getModules(String serial, int shardIndex) {
                LinkedList<IModuleDef> modules = new LinkedList<>();
                modules.add(moduleDef);
                return modules;
            }
        }, 0);
        mTest.setDevice(mMockDevice);
        mTest.setDeviceInfos(deviceInfos);
        mTest.setInvocationContext(invocationContext);
    }

    /**
     * Test the initializeModuleRepo method.
     * @throws DeviceNotAvailableException
     * @throws FileNotFoundException
     */
    @Test
    public void testInitializeModuleRepo()
            throws FileNotFoundException, DeviceNotAvailableException {
        mTest.initializeModuleRepo();
        assertEquals(deviceInfos, moduleDef.getDeviceInfos());
        assertEquals(invocationContext, moduleDef.getInvocationContext());
    }
}
