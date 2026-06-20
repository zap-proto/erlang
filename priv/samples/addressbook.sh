#!/usr/bin/env escript
%% -*- mode: erlang -*-

main(Args) ->
    try process(Args)
    catch
        C:E ->
            io:format(standard_error,
                      "~s ~p: ~s:~p~n"
                      "~p~n",
                      [escript:script_name(), Args, C, E,
                       erlang:get_stacktrace()]),
            halt(2)
    end.

process(["read"|Args]) ->
    read(Args);
process(["write"|Args]) ->
    write(Args);
process(_) ->
    io:format(standard_error,
              "Usage: ~s {read [filename] | write}~n",
              [escript:script_name()]),
    halt(1).

read([FileName]) ->
    {ok, Data} = file:read_file(FileName),
    dump_message(Data);
read([]) ->
    io:format(standard_error,
              "Reading message from stdin~n"
              "  (note, this will likely fail)~n"
              "  (if you are on windows,     )~n"
              "  (see README.                )~n~n",
              []),
    dump_message(read_stdin()).

write([]) ->
    {ok, Root} = ezap:set_root(addressbook_zap:'AddressBook'()),
    [Alice, Bob, Steve] = ezap:set(people, 3, Root),
    [AlicePhone] = ezap:set(phones, 1, Alice),
    [BobPhone1, BobPhone2] = ezap:set(phones, 2, Bob),
    [ezap:set(Field, Value, Obj)
     || {Obj, FieldValues} <-
            [{Alice,
              [{id, 123},
               {name, <<"Alice">>},
               {email, <<"alice@example.com">>},
               {employment, {school, <<"MIT">>}}
              ]},
             {AlicePhone,
              [{number, <<"555-1212">>},
               {type, mobile}]},
             {Bob,
              [{id, 456},
               {name, <<"Bob">>},
               {email, <<"bob@example.com">>},
               {employment, unemployed}
              ]},
             {BobPhone1,
              [{number, <<"555-4567">>},
               {type, home}]},
             {BobPhone2,
              [{number, <<"555-7654">>},
               {type, work}]},
             {Steve,
              [{id, 123456},
               {name, <<"Steve">>},
               {email, <<"steve@example.com">>},
               {employment, selfEmployed},
               {phones, 3},
               {phones, {0, {number, <<"555-1234">>}}},
               {phones, {0, {type, home}}},
               {phones, {1, {number, <<"555-4321">>}}},
               {phones, {1, {type, work}}},
               {phones, {2, {number, <<"070-5555">>}}},
               {phones, {2, {type, mobile}}}
              ]}
            ],
        {Field, Value} <- FieldValues],

    %% Get message data and pack it
    Data1 = ezap_serialize:pack(
              ezap_message:write(Root)),
    io:setopts([{encoding, unicode}]),
    io:put_chars(Data1).


dump_message(Data) ->
    %% unpack and read message data
    {ok, Message, <<>>} = ezap_message:read(
                            ezap_serialize:unpack(Data)),
    {ok, Root} = ezap:get_root(
                   addressbook_zap:'AddressBook'(), Message),
    People = ezap:get(people, Root),
    [dump_person(Person) || Person <- People].

dump_person(Person) ->
    io:format("#~p ", [ezap:get(id, Person)]),
    io:format("~s: ~s~n", [ezap:get(name, Person),
                           ezap:get(email, Person)]),
    Phones = ezap:get(phones, Person),
    [io:format("  ~s phone: ~s~n", [ezap:get(type, P),
                                    ezap:get(number, P)])
     || P <- Phones],
    case ezap:get(employment, Person) of
        {unemployed, void} -> io:format("  unemployed~n");
        {employer, Employer} ->
            io:format("  employer: ~s~n", [Employer]);
        {school, School} ->
            io:format("  student at: ~s~n", [School]);
        {selfEmployed, void} -> io:format("  self-employed~n")
    end.

read_stdin() ->
    read_stdin([]).

read_stdin(Acc)
  when is_list(Acc) ->
    read_stdin(file:read(standard_io, 1024), Acc).

read_stdin(eof, Acc) ->
    list_to_binary(
      lists:reverse(Acc));
read_stdin({ok, Data}, Acc) ->
    read_stdin([Data|Acc]).
