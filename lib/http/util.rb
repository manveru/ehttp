module HTTP
  module Util
    module_function

    # Returns hash of hashes representing the cookies.
    #
    # First we split the whole line by ',', then figure out which parts are
    # key=value pairs and which are parts of the previous value.
    # Then we go over the resulting array of key=value pairs and try to find
    # the first key of a cookie, once that is found we use its key as key for
    # the +result+ hash and assign the value of the key inside the hash with
    # 'value' as key.
    # All following key=value pairs are put into this inner hash until we find
    # a new cookie start.
    # Cookie start is indicated by the ';' separator, since we didn't split by
    # this before iterating over the chunks we split and unshift the right hand
    # to schedule it for the next iteration, using the left hand for the cookie
    # seed.
    #
    # The RFC points out that "key = value" is just as valid as "key=value", so
    # we handle both.
    #
    #
    # Example:
    #   'session_id = 123; path = /'
    #   # => {'session_id' => {'value' => '123', 'path' => '/'}}
    #   'session=123; path = /, expires=Mon, 18 Aug 2008 12:37:42 GMT, role=innocent bystander; path=/home, expires=Mon, 18 Aug 2008 12:38:42 GMT'
    #   # => {"session" => {
    #           "expires" => "Mon, 18 Aug 2008 12:37:42 GMT",
    #           "value" => "123",
    #           "path" => "/" },
    #         "role" => {
    #           "expires" => "Mon, 18 Aug 2008 12:38:42 GMT",
    #           "value" => "innocent bystander",
    #           "path" => "/home" } }
    #
    # --
    # This parses the value of Set-Cookie headers, apparently the authors of
    # RFC 2109 were bored and decided to make this line as hard to parse as
    # possible.  Please somebody explain to me why you would use both a
    # http-date (contains ',' for the useless day-of-week bit) and ',' as
    # separator for the key-value pairs and then spice the whole thing up by
    # using ';' as separator after the first pair for a new cookie.
    #
    #
    # TODO:
    #   * check if we really cover all cases with this and comply to some standard.
    #   * Simplify so we only have to parse each character once, but that's
    #     hard without look-(up|down|around|at-neighbours-cheat-sheet)
    # ++

    def cookie_cruncher(cookie)
      crumbs = cookie.split(/,/)
      pieces = []

      crumbs.each do |crumb|
        if crumb =~ /=/
          pieces << crumb
        else
          pieces.last << ",#{crumb}"
        end
      end

      result = {}
      current = nil

      while piece = pieces.shift
        if piece =~ /;/
          left, right = piece.split(/;/)
          pieces.unshift right

          current, value = left.split(/=/)
          current.strip!
          result[current] = {'value' => value.strip}
        else
          key, value = piece.split(/=/)
          result[current][key.strip] = value.strip
        end
      end

      return result
    end
  end
end
