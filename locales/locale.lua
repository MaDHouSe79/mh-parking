--- @class Locale
Locale = {}
Locale.__index = Locale

local function translateKey(phrase, subs)
    if type(phrase) ~= 'string' then error('TypeError: translateKey function expects arg #1 to be a string') end
    if not subs then return phrase end
    local result = phrase
    for k, v in pairs(subs) do
        local templateToFind = '%%{' .. k .. '}'
        result = result:gsub(templateToFind, tostring(v)) -- string to allow all types
    end
    return result
end

function Locale.new(_, opts)
    local self = setmetatable({}, Locale)
    self.fallback = opts.fallbackLang and Locale:new({warnOnMissing = false, phrases = opts.fallbackLang.phrases,}) or false
    self.warnOnMissing = type(opts.warnOnMissing) ~= 'boolean' and true or opts.warnOnMissing
    self.phrases = {}
    self:extend(opts.phrases or {})
    return self
end

function Locale:extend(phrases, prefix)
    for key, phrase in pairs(phrases) do
        local prefixKey = prefix and ('%s.%s'):format(prefix, key) or key
        if type(phrase) == 'table' then
            self:extend(phrase, prefixKey)
        else
            self.phrases[prefixKey] = phrase
        end
    end
end

function Locale:clear()
    self.phrases = {}
end

function Locale:replace(phrases)
    phrases = phrases or {}
    self:clear()
    self:extend(phrases)
end

function Locale:locale(newLocale)
    if (newLocale) then self.currentLocale = newLocale end
    return self.currentLocale
end

function Locale:t(key, subs)
    local phrase, result
    subs = subs or {}
    if type(self.phrases[key]) == 'string' then
        phrase = self.phrases[key]
    else
        if self.warnOnMissing then print(('^3Warning: Missing phrase for key: "%s"'):format(key)) end
        if self.fallback then return self.fallback:t(key, subs) end
        result = key
    end
    if type(phrase) == 'string' then result = translateKey(phrase, subs) end
    return result
end

function Locale:has(key)
    return self.phrases[key] ~= nil
end

function Locale:delete(phraseTarget, prefix)
    if type(phraseTarget) == 'string' then
        self.phrases[phraseTarget] = nil
    else
        for key, phrase in pairs(phraseTarget) do
            local prefixKey = prefix and prefix .. '.' .. key or key
            if type(phrase) == 'table' then
                self:delete(phrase, prefixKey)
            else
                self.phrases[prefixKey] = nil
            end
        end
    end
end