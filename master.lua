-- ====== UI TOGGLE (works with F4 key AND button tap) ======
local function toggleUI()
    mainFrame.Visible = not mainFrame.Visible
    toggleBtn.Text = mainFrame.Visible and "✖ close" or "☰ cookware"
end

-- Mobile tap
toggleBtn.Activated:Connect(toggleUI)

-- Keyboard F4 (for PC/console)
userInput.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        toggleUI()
    end
end)