%% -------------------------------------------------------------------
%%
%% riaknostic - automated diagnostic tools for Riak
%%
%% Copyright (c) 2011 Basho Technologies, Inc.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

%% Enforces a common API among all check modules.
-module(riaknostic_check).
-export([behaviour_info/1]).
-export([check/1,
         modules/0,
         print/1]).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).
-endif.

-spec behaviour_info(atom()) -> 'undefined' | [{atom(), arity()}].
behaviour_info(callbacks) ->
    [{description, 0},
     {valid, 0},
     {check, 0},
     {format, 1}];
behaviour_info(_) ->
    undefined.

-spec check(module()) -> [{lager:log_level(), module(), term()}].
check(Module) ->
    case Module:valid() of
        true ->
            [ {Level, Module, Message} || {Level, Message} <- Module:check() ];
        _ ->
            []
    end.

-spec modules() -> [module()].
modules() ->
    {ok, Mods} = application:get_key(riaknostic, modules),
    [ M || M <- Mods,
           Attr <- M:module_info(attributes),
           {behaviour, [?MODULE]} =:= Attr orelse {behavior, [?MODULE]} =:= Attr ].

-spec print({lager:log_level(), module(), term()}) -> ok.
print({Level, Mod, Term}) ->
    case Mod:format(Term) of
        {Format, Terms} ->
            lager:log(Level, self(), Format, Terms);
        String ->
            lager:log(Level, self(), String)
    end.