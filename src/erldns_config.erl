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

%% @doc Provide application-wide configuration access.
-module(erldns_config).

-export([get_address/1, get_port/0, get_num_workers/0]).

-define(DEFAULT_IPV4_ADDRESS, {127,0,0,1}).
-define(DEFAULT_IPV6_ADDRESS, {0,0,0,0,0,0,0,1}).
-define(DEFAULT_PORT, 53).
-define(DEFAULT_NUM_WORKERS, 10).

%% @doc Get the IP address (either IPv4 or IPv6) that the DNS server
%% should listen on.
%%
%% IPv4 default: 127.0.0.1
%% IPv6 default: ::1
-spec get_address(inet | inet6) -> inet:ip_address().
get_address(inet) ->
  case application:get_env(erldns, inet4) of
    {ok, Address} -> parse_address(Address);
    _ -> ?DEFAULT_IPV4_ADDRESS
  end;
get_address(inet6) ->
  case application:get_env(erldns, inet6) of
    {ok, Address} -> parse_address(Address);
    _ -> ?DEFAULT_IPV6_ADDRESS
  end.

%% @doc The the port that the DNS server should listen on.
%%
%% Default: 53
-spec get_port() -> inet:port_number().
get_port() ->
  case application:get_env(erldns, port) of
    {ok, Port} -> Port;
    _ -> ?DEFAULT_PORT
  end.

%% @doc Get the number of workers to run for handling DNS requests.
%%
%% Default: 10
-spec get_num_workers() -> non_neg_integer().
get_num_workers() ->
  case application:get_env(erldns, num_workers) of
    {ok, NumWorkers} -> NumWorkers;
    _ -> ?DEFAULT_NUM_WORKERS
  end.

% Private functions

parse_address(Address) when is_list(Address) ->
  {ok, Tuple} = inet_parse:address(Address),
  Tuple;
parse_address(Address) -> Address.
