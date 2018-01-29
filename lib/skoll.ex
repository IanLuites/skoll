defmodule Skoll do
  @moduledoc ~S"""
  Data driven API design.
  """

  ### API ###

  @doc false
  defmacro __using__(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      @skoll_settings opts
      @before_compile Skoll
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    [original] = env.context_modules
    settings = Module.get_attribute(original, :skoll_settings)
    namespace = settings[:namespace] || Elixir
    fallback = settings[:fallback]
    web_controller = settings[:web_controller]

    api_name =
      original
      |> Atom.to_string()
      |> String.split(".", trim: true)
      |> List.last()
      |> String.trim_trailing("API")
      |> Kernel.<>("Controller")
      |> String.to_atom()

    expose =
      original
      |> Module.definitions_in(:def)
      |> Enum.filter(&(elem(&1, 1) <= 2))

    Module.create(
      Module.concat([namespace, API, api_name]),
      create_api_controller(original, namespace, expose, fallback),
      Macro.Env.location(__ENV__)
    )

    if web_controller do
      Module.create(
        Module.concat([namespace, api_name]),
        create_web_controller(original, namespace, expose, web_controller),
        Macro.Env.location(__ENV__)
      )
    end

    nil
  end

  defp create_api_controller(original, namespace, expose, fallback) do
    Enum.reduce(
      expose,
      quote do
        use Phoenix.Controller, namespace: unquote(namespace)
        import Plug.Conn
        import unquote(Module.concat([namespace, Router, Helpers]))
        import unquote(Module.concat([namespace, Gettext]))

        if unquote(fallback), do: action_fallback(unquote(fallback))
      end,
      fn
        {name, 0}, acc ->
          quote do
            unquote(acc)

            def unquote(name)(conn, _params) do
              data = unquote(original).unquote(name)()
              render(conn, unquote(to_string(name) <> ".json"), data)
            end
          end

        {name, 1}, acc ->
          quote do
            unquote(acc)

            def unquote(name)(conn, params) do
              data = unquote(original).unquote(name)(params)
              render(conn, unquote(to_string(name) <> ".json"), data)
            end
          end

        {name, 2}, acc ->
          quote do
            unquote(acc)

            def unquote(name)(conn, params) do
              data = unquote(original).unquote(name)(conn, params)
              render(conn, unquote(to_string(name) <> ".json"), data)
            end
          end
      end
    )
  end

  defp create_web_controller(original, namespace, expose, web_controller) do
    Enum.reduce(
      expose,
      quote do
        @moduledoc false
        use unquote(namespace), :controller
      end,
      fn
        {name, 0}, acc ->
          quote do
            unquote(acc)

            def unquote(name)(conn, params) do
              data = unquote(original).unquote(name)()
              unquote(web_controller).unquote(name)(conn, params, data)
            end
          end

        {name, 1}, acc ->
          quote do
            unquote(acc)

            def unquote(name)(conn, params) do
              data = unquote(original).unquote(name)(params)
              unquote(web_controller).unquote(name)(conn, params, data)
            end
          end

        {name, 2}, acc ->
          quote do
            unquote(acc)

            def unquote(name)(conn, params) do
              data = unquote(original).unquote(name)(conn, params)
              unquote(web_controller).unquote(name)(conn, params, data)
            end
          end
      end
    )
  end
end
