-- Funkcja do usuwania obiektów przyczepionych do gracza
function RemoveAttachedProps()
    local playerPed = PlayerPedId()
    local attachedObjects = {}
    
    -- Pobieranie wszystkich obiektów w okolicy gracza
    for obj in EnumerateObjects() do
        if IsEntityAttachedToEntity(obj, playerPed) then
            table.insert(attachedObjects, obj)
        end
    end
    
    -- Usuwanie znalezionych obiektów
    for _, obj in ipairs(attachedObjects) do
        DeleteObject(obj)
    end
end

-- Enumerator obiektów w grze
function EnumerateObjects()
    return coroutine.wrap(function()
        local handle, object = FindFirstObject()
        if not object then
            EndFindObject(handle)
            return
        end
        
        local enum = {handle = handle, destructor = EndFindObject}
        setmetatable(enum, entityEnumerator)
        
        local next = true
        repeat
            coroutine.yield(object)
            next, object = FindNextObject(handle)
        until not next
        
        enum.destructor, enum.handle = nil, nil
        EndFindObject(handle)
    end)
end

-- Hook do zdarzenia (np. przy użyciu komendy)
RegisterCommand("propfix", function()
    RemoveAttachedProps()
end, false)

-- Dodawanie komendy do gry
TriggerEvent('chat:addSuggestion', '/propfix', 'Usuń wszystkie propy przyczepione do gracza.')
