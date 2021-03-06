/*
 * Copyright (c) 2017 Vegard IT GmbH, http://vegardit.com
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
package hx.concurrent;

import hx.concurrent.atomic.AtomicInt;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
interface Service<T> {

    public var id(default, null):T;

    public var state(default, null):ServiceState;

    public function stop():Void;

    public function toString():String;
}


enum ServiceState {
    RUNNING;
    STOPPING;
    STOPPED;
}


@:abstract
class ServiceBase implements Service<Int> {

    static var _ids = new AtomicInt();

    public var id(default, never):Int = _ids.incrementAndGet();

    public var state(default, set):ServiceState = RUNNING;
    var _stateLock:RLock = new RLock();

    function set_state(s:ServiceState) {
        switch(s) {
            case RUNNING: trace('[$this] is running.');
            case STOPPING: trace('[$this] is stopping.');
            case STOPPED: trace('[$this] is stopped.');
        }
        return state = s;
    }

    function new() {
        trace('[$this] instantiated.');
    }

    public function stop() {
        _stateLock.execute(function() {
            if (state == RUNNING) {
                state = STOPPING;
            }
        });
    }

    inline
    public function toString():String {
        return Type.getClassName(Type.getClass(this)) + "#" + id;
    }
}
