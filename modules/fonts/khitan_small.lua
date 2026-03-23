function nextex_khs_render(input)
  local function cluster_rows(cluster)
    local chars = 0
    local type_b = false
    for _, cp in utf8.codes(cluster) do
      if cp == 0x16FE4 then
        if chars == 1 then
          type_b = true
        end
      else
        chars = chars + 1
      end
    end
    if chars <= 1 then
      return 1
    end
    if type_b then
      return 1 + math.floor(chars / 2)
    end
    return math.floor((chars + 1) / 2)
  end

  local max_rows = 1
  for cluster in string.gmatch(input, "%S+") do
    local rows = cluster_rows(cluster)
    if rows > max_rows then
      max_rows = rows
    end
  end

  local first_cluster = true
  local bs = string.char(92)
  tex.sprint(bs .. "fontkhssetrunmaxrows{" .. tostring(max_rows) .. "}")

  for cluster in string.gmatch(input, "%S+") do
    if not first_cluster then
      tex.sprint(bs .. "fontkhsspace")
    end
    first_cluster = false
    tex.sprint(bs .. "fontkhsbegincluster")

    local chars = {}
    for _, cp in utf8.codes(cluster) do
      if cp == 0x16FE4 then
        if #chars == 1 then
          tex.sprint(bs .. "fontkhsmarktypeb")
        end
      else
        chars[#chars + 1] = utf8.char(cp)
      end
    end

    for _, ch in ipairs(chars) do
      tex.sprint(bs .. "fontkhspushchar{" .. ch .. "}")
    end

    tex.sprint(bs .. "fontkhsrendercluster")
  end
end
