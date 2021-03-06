%% Copyright (c) 2012-2013, Aetrion LLC
%%
%% Permission to use, copy, modify, and/or distribute this software for any
%% purpose with or without fee is hereby granted, provided that the above
%% copyright notice and this permission notice appear in all copies.
%%
%% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
%% WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
%% MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
%% ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
%% WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
%% ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
%% OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

%% @doc A process to check the zone cache on a regular basis for outdated
%% zones. When an outdated zone is identified it is refreshed from the zone
%% server.
-module(erldns_zone_checker).

-behavior(gen_server).

% API
-export([start_link/0, check/0, check_zones/1]).

% Gen server hooks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
  ]).

-define(SERVER, ?MODULE).
-define(CHECK_INTERVAL, 1000 * 600). % Every N seconds

-record(state, {tref}).

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

check() ->
  NamesAndVersions = erldns_zone_cache:zone_names_and_versions(),
  lager:debug("Running zone check on ~p zones", [length(NamesAndVersions)]),
  check_zones(NamesAndVersions).

check_zones(NamesAndVersions) ->
  gen_server:cast(?SERVER, {check_zones, NamesAndVersions}).

init([]) ->
  {ok, Tref} = timer:apply_interval(?CHECK_INTERVAL, ?MODULE, check, []),
  {ok, #state{tref = Tref}}.

handle_call(_Message, _From, State) ->
  {reply, ok, State}.

handle_cast({check_zones, NamesAndVersions}, State) ->
  lists:map(fun({Name, Version}) -> send_zone_check(Name, Version) end, NamesAndVersions),
  {noreply, State}.

handle_info(_Message, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_PreviousVersion, State, _Extra) ->
  {ok, State}.

%% Private API
send_zone_check(Name, Sha) ->
  %lager:debug("Sending zone check for ~p (~p)", [Name, Sha]),
  case Sha of
    [] -> lager:debug("Skipping check of ~p", [Name]);
    _ -> erldns_zone_client:fetch_zone(Name, Sha)
  end,
  ok.
