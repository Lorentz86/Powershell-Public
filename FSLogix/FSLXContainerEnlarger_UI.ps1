# Add the Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create a Windows Forms form
$form = New-Object System.Windows.Forms.Form
$form.Text = "FSLogix Container Extender"
$form.Width = 600
$form.Height = 280

# Create a label for the username
$label = New-Object System.Windows.Forms.Label
$label.Text = "Enter Username"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(20, 20)

# Create a text box for the username
$usernameTextBox = New-Object System.Windows.Forms.TextBox
$usernameTextBox.Location = New-Object System.Drawing.Point(20, 50)
$usernameTextBox.Width = 200

# Label for container path
$containerlabel = New-Object System.Windows.Forms.Label
$containerlabel.Text = "Path to user containers (e.g., E:\FSLogix):"
$containerlabel.AutoSize = $true
$containerlabel.Location = New-Object System.Drawing.Point(20, 90)  # Adjusted vertical position

# Text box for container path
$containerInputText = New-Object System.Windows.Forms.TextBox
$containerInputText.Location = New-Object System.Drawing.Point(20, 120)  # Adjusted vertical position
$containerInputText.Text = "E:\FSLogix"
$containerInputText.Width = 200

# Label for container choice
$containerTypeLabel = New-Object System.Windows.Forms.Label
$containerTypeLabel.Text = "User container to enlarge?"
$containerTypeLabel.AutoSize = $true
$containerTypeLabel.Location = New-Object System.Drawing.Point(250, 20)

# Radio button for Profile
$RadioA = New-Object Windows.Forms.RadioButton
$RadioA.Location = New-Object Drawing.Point(250, 40)
$RadioA.Size = New-Object Drawing.Size(200, 20)
$RadioA.Text = "Profile"
$RadioA.Checked = $true  # Default to RadioA selected

# Radio button for Office
$RadioB = New-Object Windows.Forms.RadioButton
$RadioB.Location = New-Object Drawing.Point(250, 60)
$RadioB.Size = New-Object Drawing.Size(200, 20)
$RadioB.Text = "Office"

# Create a label for the status
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Status:"
$statusLabel.AutoSize = $true
$statusLabel.Location = New-Object System.Drawing.Point(250, 90)

# Create a label for the status text
$statustextLabel = New-Object System.Windows.Forms.Label
$statustextLabel.Text = "No action"
$statustextLabel.AutoSize = $true
$statustextLabel.Location = New-Object System.Drawing.Point(250, 120)

# Container Path Label
$containerpathlabel = New-Object System.Windows.Forms.Label
$containerpathlabel.Text = ""
$containerpathlabel.AutoSize = $true
$containerpathlabel.Location = New-Object System.Drawing.Point(100, 205)

# Add an event handler to handle the radio button selection change
$RadioA.Add_CheckedChanged({
    $RadioB.Checked = !$RadioA.Checked
})

$RadioB.Add_CheckedChanged({
    $RadioA.Checked = !$RadioB.Checked
})

# Create an OK button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "OK"
$okButton.Location = New-Object System.Drawing.Point(20, 160)

# Create a Cancel button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = "Cancel"
$cancelButton.Enabled = $true
$cancelButton.Location = New-Object System.Drawing.Point(145, 160)  # Adjusted vertical position

# Execute Button
$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Text = "Execute"
$executeButton.Enabled = $false
$executeButton.Location = New-Object System.Drawing.Point(20, 200)  # Adjusted vertical position

# Variable to check if the container can be resized
$finalCheck = $true

# Add a Click event handler to the OK button
$okButton.Add_Click({

    try
    {
        $executeButton.Enabled = $false
        $containerpathlabel.Text = ""
        # Execute your script here
        # Step 1:
        $statustextLabel.Text = "Step 1 of 5,`n`nLooking up the user container $($usernameTextBox.Text)"
        Start-Sleep -Seconds 3

        Import-Module "\\pathtomodule\Test-FSLXUserContainer.ps1" -Force

        # Check if the container exists
        $Containerfound = Test-FSLXUserContainer -Username $usernameTextBox.Text -Path $containerInputText.Text
        if (!$Containerfound)
        {
            $finalCheck = $false
            $statustextLabel.Text = "Step 1 of 5,`n`nContainer not found for user $($usernameTextBox.Text),`nPlease check the path."
            return
        }
        else
        {
            $statustextLabel.Text = "Step 1 of 5,`n`nContainer for $($usernameTextBox.Text) found"
            Start-Sleep -Seconds 3
        }
        # Step 2
        $statustextLabel.Text = "Step 2 of 5,`n`nChecking if user $($usernameTextBox.Text) is logged off"
        Start-Sleep -Seconds 3

        # Check if the user is logged in
        Import-Module "\\pathtomodule\Test-RDSUserSession.ps1" -Force
        $UserOnline = Test-RDSUserSession -Username $usernameTextBox.Text -ConnectionBroker "connectionbroker"

        if ($UserOnline)
        {
            $finalCheck = $false
            $statustextLabel.Text = "Step 2 of 5,`n`nUser $($usernameTextBox.Text) is logged in.`n`nPlease have the user log out first."
            return
        }
        else
        {
            $statustextLabel.Text = "Step 2 of 5,`n`n$($usernameTextBox.Text) is logged out"
            Start-Sleep -Seconds 3
        }

        # Get container information
        $statustextLabel.Text = "Step 3 of 5,`n`nRetrieving container location for $($usernameTextBox.Text)"
        Start-Sleep -Seconds 3

        Import-Module "\\pathtomodule\Get-FSLXContainerpath.ps1" -Force

        if ($RadioA.Checked)
        {
            $containertype = "profile"
        }
        else
        {
            $containertype = "office"
        }

        $ContainerPath = Get-FSLXContainerPath -Username $usernameTextBox.Text -Source $containerInputText.Text -containertype $containertype
        $containerpathlabel.Text = $ContainerPath
    }
    catch
    {
        $finalCheck = $false
        $statustextLabel.Text = "There is a problem with the script."
    }

    # Resize the container
    $statustextLabel.Text = "Step 4 of 5,`n`nControllers ready for $($usernameTextBox.Text) container.`nPress Execute to start"
    $executeButton.Enabled = $true
    return
})

$cancelButton.Add_Click({
    $form.Dispose()
})

$executeButton.Add_Click({
    if ($finalcheck)
    {
        try
        {
            $cancelButton.Enabled = $false
            $statustextLabel.Text = "Step 5 of 5,`n`nResizing the $($usernameTextBox.Text) container."
            Import-Module "\\pathtomodule\Resize-FSLXContainer.ps1" -Force
            $executeButton.Enabled = $false
            $UserContainerEnlarged = Resize-FSLXContainer -Source $containerpathlabel.Text -GigaByte 5 -Dynamic 0 -Replace $True -Verbose

            if ($UserContainerEnlarged.count -gt 1)
            {
                $issue = $UserContainerEnlarged | Select-Object -Skip 1
                $statustextLabel.Text = "Step 5 of 5,`nResizing failed for $($usernameTextBox.Text).`nThe following issue occurred: $($issue)"
                $executeButton.Enabled = $false
                $cancelButton.Enabled = $true
                return
            }
            Else
            {
                if ($UserContainerEnlarged -eq $true)
                {
                    $statustextLabel.Text = "Step 5 of 5, `nContainer resized successfully for $($usernameTextBox.Text)."
                    $executeButton.Enabled = $false
                    # Show a popup message with "Done"
                    [System.Windows.Forms.MessageBox]::Show("Done", "Script Executed")
                    $cancelButton.Enabled = $true
                    $form.Dispose()
                    return
                }
                else
                {
                    $statustextLabel.Text = "Step 5 of 5,`nResizing failed for $($usernameTextBox.Text). Please check manually."
                    $executeButton.Enabled = $false
                    $cancelButton.Enabled = $true
                    return
                }
            }

            # Simulate a delay of 5 seconds
            Start-Sleep -Seconds 1
        }
        catch
        {
            $exception = $_.Exception
            $executeButton.Enabled = $false
            $cancelButton.Enabled = $true
            $statustextLabel.Text = "Step 5 of 5, Resizing failed for $($usernameTextBox.Text).`nThe following issue occurred: $($exception)"
        }
    }
    else
    {
        $statustextLabel.Text = "Step 5 of 5,`n`nFinal check failed."
        $executeButton.Enabled = $false
        $cancelButton.Enabled = $true
    }
})

# Add the controls to the form
$form.Controls.Add($label)
$form.Controls.Add($usernameTextBox)
$form.Controls.Add($containerlabel)
$form.Controls.Add($containerInputText)
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)
$form.Controls.Add($cancelButton)
$form.Controls.Add($executeButton)
$Form.Controls.Add($statustextLabel)
$Form.Controls.Add($containerpathlabel)
$form.Controls.Add($containerTypeLabel)
$Form.Controls.Add($statusLabel)
$Form.Controls.Add($RadioA)
$Form.Controls.Add($RadioB)

# Show the form
$form.ShowDialog()

# Close the form upon exit
$form.Dispose()
