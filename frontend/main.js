document.getElementById('createAccountForm').addEventListener('submit', function(event) {
    event.preventDefault();
    const email = document.getElementById('email').value;

    fetch('/send-verification-email', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ email: email })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert(`Verification email sent to ${email}. Please check your inbox.`);
            document.getElementById('createAccountForm').style.display = 'none';
            document.getElementById('verifyTokenForm').style.display = 'block';
        } else {
            alert('Error sending verification email. Please try again.');
        }
    });
});

document.getElementById('verifyTokenForm').addEventListener('submit', function(event) {
    event.preventDefault();
    const token = document.getElementById('token').value;

    fetch('/verify-token', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ token: token })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('Email verified successfully! Account created.');
        } else {
            alert('Invalid verification token. Please try again.');
        }
    });
});